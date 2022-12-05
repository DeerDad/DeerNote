echo 'Generating proto files'

.\protoc.exe --dart_out=grpc:../app/lib/generated -I../protos p01.proto