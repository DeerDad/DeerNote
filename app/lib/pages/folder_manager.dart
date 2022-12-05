import 'package:app/server/server_manager.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/generated/p01.pb.dart';
import 'package:app/utils/log.dart';
import 'package:uuid/uuid.dart';
import 'package:app/providers/home_provider.dart';
import 'package:get_it/get_it.dart';

class PageMemoryCache {
  PageMemoryCache(
      {required this.selfPageProfile,
      required this.parentPageProfile,
      this.selfPageDetail,
      this.expanded = false,
      this.edittingName = false});

  PageProfile parentPageProfile;
  late PageProfile selfPageProfile;
  PageDetail? selfPageDetail;
  bool expanded = false;
  bool edittingName = false;
  bool recycleBinSelected = false;
}

enum PageOp {
  PageOp_Update,
  PageOp_Delete,
}

class FolderManager {
  UserFolder? _userFolder;
  Map<String, PageMemoryCache> _pagesQuickMap = {};
  Map<String, PageOp> _waitingPages = {};
  Uuid uuid = Uuid();

  set userFolder(UserFolder value) {
    _userFolder = value;

    _pagesQuickMap.clear();
    setupQuickMap();
  }

  setupQuickMap() {
    // add root pages
    for (int i = 0; i < _userFolder!.rootPage.subPages.length; i++) {
      setupQuickMapOnePageProfile(
          _userFolder!.rootPage, _userFolder!.rootPage.subPages[i]);
    }
  }

  UserFolder get userFolder {
    return _userFolder!;
  }

  PageMemoryCache? findPageMemoryCache(String uuid) {
    return _pagesQuickMap[uuid];
  }

  setupQuickMapOnePageProfile(
      PageProfile parentPageProfile, PageProfile pageProfile,
      {bool editingName = false}) {
    // add self
    _pagesQuickMap[pageProfile.uuid] = PageMemoryCache(
        selfPageProfile: pageProfile,
        parentPageProfile: parentPageProfile,
        edittingName: editingName);

    // add subPages
    for (int i = 0; i < pageProfile.subPages.length; i++) {
      setupQuickMapOnePageProfile(pageProfile, pageProfile.subPages[i]);
    }
  }

  addNewPage(PageProfile? parentPageProfile) {
    PageProfile pageProfile =
        PageProfile(name: "new Page", uuid: uuid.v4(), deleted: false);
    if (parentPageProfile == null) {
      parentPageProfile = _userFolder!.rootPage;
    }

    parentPageProfile.subPages.add(pageProfile);

    if (parentPageProfile != _userFolder!.rootPage)
      _pagesQuickMap[parentPageProfile.uuid]!.expanded = true;

    setupQuickMapOnePageProfile(parentPageProfile, pageProfile,
        editingName: true);
    GetIt.I.get<HomeProvider>().homeEvent = [HomeEvent.UpdateUserFolder];

    _folderDirty = true;
  }

  bool _folderDirty = false;
  saveUserFolder() {
    ServerManager sm = GetIt.I.get<ServerManager>();
    sm.updateUserFolder();
  }

  tick() {
    if (_folderDirty) {
      saveUserFolder();
      _folderDirty = false;
    }

    _tickPages();
  }

  _tickPages() {
    List<String> deletePages = [];
    List<String> updatePages = [];

    _waitingPages.forEach((key, value) {
      if (value == PageOp.PageOp_Delete) {
        deletePages.add(key);
      } else if (value == PageOp.PageOp_Update) {
        updatePages.add(key);
      }
    });
    _waitingPages.clear();

    if (deletePages.length > 0) {
      ServerManager sm = GetIt.I.get<ServerManager>();
      sm.deleteUserPages(deletePages);
      Log.debug("deleteUserPages ${deletePages.toString()}");
    }

    if (updatePages.length > 0) {
      ServerManager sm = GetIt.I.get<ServerManager>();
      sm.updateUserPages(updatePages);
    }
  }

  iterateMarkDeleted(PageProfile pageProfile) {
    pageProfile.deleted = true;
    _pagesQuickMap[pageProfile.uuid]!.recycleBinSelected = false;

    if (pageProfile.uuid == GetIt.I.get<HomeProvider>().lastSelectPage) {
      GetIt.I.get<HomeProvider>().selectPage("");
    }

    pageProfile.subPages.forEach((element) {
      iterateMarkDeleted(element);
    });
  }

  void moveToRecyclePage(String pageUuid) {
    PageMemoryCache? pageMemoryCache = _pagesQuickMap[pageUuid];
    if (pageMemoryCache == null) {
      Log.warn("${pageUuid} page null");
      return;
    }

    List<HomeEvent> events = [
      HomeEvent.UpdateRecycleBin,
      HomeEvent.UpdateUserFolder
    ];

    // 标记自身和所有子节点删除
    iterateMarkDeleted(pageMemoryCache.selfPageProfile);
    _folderDirty = true;

    GetIt.I.get<HomeProvider>().homeEvent = events;
  }

  bool canAcceptIn(PageMemoryCache page, PageMemoryCache receivePage) {
    // receivePage不能接受page的条件：
    // receivePage在page的子节点里
    // receivePage == page
    if (receivePage.selfPageProfile == page.selfPageProfile) {
      return false;
    }

    PageProfile checkPageProfile = receivePage.parentPageProfile;
    while (checkPageProfile != _userFolder!.rootPage) {
      if (checkPageProfile == page.selfPageProfile) {
        return false;
      }

      checkPageProfile =
          findPageMemoryCache(checkPageProfile.uuid)!.parentPageProfile;
    }

    return true;
  }

  bool canAcceptSibling(
      PageMemoryCache page, PageMemoryCache sibling, bool front) {
    if (page.selfPageProfile == sibling.selfPageProfile) {
      return false;
    }

    // 转换为兄弟的父类能不能接受page
    PageProfile pageProfile = sibling.parentPageProfile;
    if (pageProfile == _userFolder!.rootPage) {
      // root 肯定能接受
      return true;
    }

    PageMemoryCache pageMemoryCache = _pagesQuickMap[pageProfile.uuid]!;
    return canAcceptIn(page, pageMemoryCache);
  }

  AcceptIn(PageMemoryCache page, PageMemoryCache receivePage) {
    if (canAcceptIn(page, receivePage) == false) {
      return;
    }

    // 首先判断receivePage是否已经包含page，如果包含，则不处理
    if (receivePage.selfPageProfile.subPages.contains(page.selfPageProfile)) {
      return;
    }

    // 开始正式转移page
    // 1：断开page父辈的关系
    // 2: receivePage加入page
    // 3: 修改quickmap映射关系
    assert(page.parentPageProfile.subPages.contains(page.selfPageProfile));
    page.parentPageProfile.subPages.remove(page.selfPageProfile);

    receivePage.selfPageProfile.subPages.add(page.selfPageProfile);

    assert(_pagesQuickMap[page.selfPageProfile.uuid] == page);
    page.parentPageProfile = receivePage.selfPageProfile;

    List<HomeEvent> events = [HomeEvent.UpdateUserFolder];
    if (page.selfPageProfile.uuid ==
        GetIt.I.get<HomeProvider>().lastSelectPage) {
      events.add(HomeEvent.UpdateEditorHead);
    }

    GetIt.I.get<HomeProvider>().homeEvent = events;
    _folderDirty = true;
  }

  AcceptSibling(PageMemoryCache page, PageMemoryCache sibling, bool front) {
    if (canAcceptSibling(page, sibling, front) == false) {
      return;
    }

    // 开始正式转移page
    // 1：断开page父辈的关系
    // 2: 找到sibling的父节点，并确定索引
    // 2: 父节点加入page
    // 3: 修改quickmap映射关系
    assert(page.parentPageProfile.subPages.contains(page.selfPageProfile));
    page.parentPageProfile.subPages.remove(page.selfPageProfile);

    PageProfile parentPageProfile = sibling.parentPageProfile;
    int index = parentPageProfile.subPages.indexOf(sibling.selfPageProfile);
    assert(index >= 0);

    index = front ? index : index + 1;
    parentPageProfile.subPages.insert(index, page.selfPageProfile);

    assert(_pagesQuickMap[page.selfPageProfile.uuid] == page);
    page.parentPageProfile = parentPageProfile;

    List<HomeEvent> events = [HomeEvent.UpdateUserFolder];
    if (page.selfPageProfile.uuid ==
        GetIt.I.get<HomeProvider>().lastSelectPage) {
      events.add(HomeEvent.UpdateEditorHead);
    }

    GetIt.I.get<HomeProvider>().homeEvent = events;
    _folderDirty = true;
  }

  getSubPages(PageProfile pageProfile, List<PageProfile> pages) {
    pages.add(pageProfile);
    for (int i = 0; i < pageProfile.subPages.length; i++) {
      getSubPages(pageProfile.subPages[i], pages);
    }
  }

  List<PageMemoryCache> genPagesInRecycleBin() {
    List<PageMemoryCache> pages = [];
    _pagesQuickMap.forEach((key, value) {
      if (value.selfPageProfile.deleted) pages.add(value);
    });

    return pages;
  }

  opAllRecycleBinPages(bool select) {
    List<PageMemoryCache> pages = genPagesInRecycleBin();
    pages.forEach((element) {
      element.recycleBinSelected = select;
    });
    GetIt.I.get<HomeProvider>().homeEvent = [HomeEvent.UpdateRecycleBin];
  }

  bool get hasSelectedRecycleBinPagesCount {
    List<PageMemoryCache> pages = genPagesInRecycleBin();
    for (int i = 0; i < pages.length; i++) {
      if (pages[i].recycleBinSelected) return true;
    }

    return false;
  }

  bool get hasRecycleBinPagesCount {
    List<PageMemoryCache> pages = genPagesInRecycleBin();
    return !pages.isEmpty;
  }

  opSelectedRecycleBinPages(bool delete) {
    List<PageMemoryCache> pageCaches = genPagesInRecycleBin();
    List<String> pages = [];
    pageCaches.forEach((element) {
      if (element.recycleBinSelected) pages.add(element.selfPageProfile.uuid);
    });

    pages.forEach((element) {
      if (delete) {
        _doDeleteSelectedRecycleBinPages(element);
      } else {
        _doRecoverSelectedRecycleBinPages(element);
      }
    });

    GetIt.I.get<HomeProvider>().homeEvent = [
      HomeEvent.UpdateRecycleBin,
      HomeEvent.UpdateUserFolder
    ];
    _folderDirty = true;
  }

  _doRecoverSubPages(PageProfile pageProfile) {
    pageProfile.deleted = false;
    for (int i = 0; i < pageProfile.subPages.length; i++) {
      _doRecoverSubPages(pageProfile.subPages[i]);
    }
  }

  // 为了统一概念，删除和恢复都是以自身和subpages作为一个整体进行的
  _doRecoverSelectedRecycleBinPages(String uuid) {
    if (_pagesQuickMap.containsKey(uuid) == false) return;
    // 恢复操作
    // 递归标记page不删除
    PageProfile pageProfile = _pagesQuickMap[uuid]!.selfPageProfile;
    if (pageProfile.deleted == false) return;
    _doRecoverSubPages(pageProfile);

    PageProfile parentPageProfile = _pagesQuickMap[uuid]!.parentPageProfile;
    if (parentPageProfile.deleted == true) {
      // 如果parent是删除状态，需要更改parent
      assert(parentPageProfile.subPages.contains(pageProfile));
      parentPageProfile.subPages.remove(pageProfile);

      _userFolder!.rootPage.subPages.add(pageProfile);
      _pagesQuickMap[uuid]!.parentPageProfile = _userFolder!.rootPage;
    }
  }

  _doDeleteSubPages(PageProfile pageProfile, Set<String> deletedPages) {
    for (int i = 0; i < pageProfile.subPages.length; i++) {
      deletedPages.add(pageProfile.subPages[i].uuid);
      _doDeleteSubPages(pageProfile.subPages[i], deletedPages);
    }
  }

  _doDeleteSelectedRecycleBinPages(String uuid) {
    if (_pagesQuickMap.containsKey(uuid) == false) return;

    // 删除操作
    // 1: 断开和parent的关系
    // 2: 递归删除subpages
    // 3: 从quickmap中清除
    PageProfile parentPageProfile = _pagesQuickMap[uuid]!.parentPageProfile;
    PageProfile pageProfile = _pagesQuickMap[uuid]!.selfPageProfile;
    assert(parentPageProfile.subPages.contains(pageProfile));
    parentPageProfile.subPages.remove(pageProfile);

    Set<String> deletedPages = {uuid};
    _doDeleteSubPages(pageProfile, deletedPages);

    deletedPages.forEach((element) {
      _pagesQuickMap.remove(element);
      _waitingPages[element] = PageOp.PageOp_Delete;
    });
  }

  int indexOfFirstUndeletedChild(PageProfile pageProfile) {
    for (int i = 0; i < pageProfile.subPages.length; i++) {
      if (pageProfile.subPages[i].deleted == false) return i;
    }

    return -1;
  }

  getPagesChain(String uuid, List<PageMemoryCache> pageChain) {
    if (_pagesQuickMap.containsKey(uuid) == false) {
      return;
    }

    pageChain.add(_pagesQuickMap[uuid]!);
    getPagesChain(pageChain.last.parentPageProfile.uuid, pageChain);
  }

  storePageDetail(String uuid, PageDetail pageDetail) {
    assert(_pagesQuickMap.containsKey(uuid));
    assert(pageDetail.uuid == uuid);
    assert(pageDetail.account ==
        GetIt.I.get<AppRuntimeData>().userProfile.account);
    _pagesQuickMap[uuid]!.selfPageDetail = pageDetail;
  }

  updatePageDetail(String uuid, String content) {
    assert(_pagesQuickMap.containsKey(uuid));
    assert(_pagesQuickMap[uuid]!.selfPageDetail != null);
    _pagesQuickMap[uuid]!.selfPageDetail!.content = content;
    _waitingPages[uuid] = PageOp.PageOp_Update;
  }

  updatePageName(String uuid, String newName) {
    assert(_pagesQuickMap.containsKey(uuid));

    _pagesQuickMap[uuid]!.selfPageProfile.name = newName;

    List<HomeEvent> events = [HomeEvent.UpdateRecycleBin];

    if (GetIt.I.get<HomeProvider>().lastSelectPage == uuid) {
      events.add(HomeEvent.UpdateEditorHead);
    }

    GetIt.I.get<HomeProvider>().homeEvent = events;
    _folderDirty = true;
  }
}
