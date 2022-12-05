import 'package:app/generated/p01.pb.dart';
import 'package:app/pages/folder_manager.dart';
import 'package:app/server/server_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:app/views/home_view.dart';
import 'package:app/views/login_view.dart';
import '../../common/spacing.dart';
import '../../../utils/log.dart';
import '../../overlay/base/app_overlay.dart';
import '../../overlay/page_more_popup_menu.dart';
import '../../overlay/base/popup_menu.dart';
import 'package:dartz/dartz.dart';
import '../../dialog/flex_setting_dialog.dart';
import 'package:get_it/get_it.dart';
import '../../../utils/app_runtime_data.dart';
import '../../../style/layout.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/views/home/menu/catalog/catalog_item.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/views/common/app_button.dart';

class HomeHeadBar extends StatelessWidget {
  const HomeHeadBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildUserProfileSection(),
        VSpace(5),
        buldMenuSection(context)
      ],
    );
  }

  Widget buildUserProfileSection() {
    return SizedBox(
      height: AppLayout.catalogItemGridSize,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Selector<HomeProvider, List<HomeEvent>>(
          selector: (p0, p1) {
            return p1.homeEvent;
          },
          shouldRebuild: (previous, next) {
            return next.contains(HomeEvent.UpdateNickname);
          },
          builder: (context, value, child) {
            return Text(
              GetIt.I.get<AppRuntimeData>().userProfile.nickname,
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    );
  }

  Widget buldMenuSection(BuildContext context) {
    return Wrap(
      children: [
        CatalogItemGrid(
            child: AppButton(
          tip: LocaleKeys.user_profile.tr(),
          icon: Icons.person_rounded,
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return FlexSettingDialog(AppLayout.profileSettingItems);
                });
          },
        )),
        HSpace(5),
        CatalogItemGrid(
            child: AppButton(
          icon: Icons.add_rounded,
          tip: LocaleKeys.add_new_page.tr(),
          onTap: () {
            FolderManager folderManager = GetIt.I.get<FolderManager>();
            folderManager.addNewPage(null);
          },
        )),
        HSpace(5),
        CatalogItemGrid(
            child: AppButton(
          tip: LocaleKeys.recycle_bin.tr(),
          icon: Icons.delete_rounded,
          onTap: () {
            GetIt.I.get<HomeProvider>().homeMode = HomeMode.RecycleBinMode;
          },
        )),
        HSpace(5),
        CatalogItemGrid(
            child: AppButton(
          tip: LocaleKeys.user_setting.tr(),
          icon: Icons.settings_rounded,
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return FlexSettingDialog(AppLayout.homeSettingItems);
                });
          },
        )),
        HSpace(5),
        CatalogItemGrid(
            child: AppButton(
          tip: LocaleKeys.logout.tr(),
          icon: Icons.logout_rounded,
          onTap: () {
            ServerManager sm = GetIt.I.get<ServerManager>();
            sm.logout();
            Navigator.of(context)
                .pushReplacementNamed(LoginView.LOGIN_ROUTE_NAME);
          },
        )),
        HSpace(5),
      ],
    );
  }
}
