GO_MODULE=github.com/OleksUMD/proto-example

.PHONY: clean protoc build tidy run pipeline-build pipeline-init clean-gateway protoc-go-gateway protoc-openapiv2-gateway build-gateway pipeline-init-gateway pipeline-build-gateway

run:
	go run .

tidy:
	go mod tidy

build: clean protoc tidy
build-gateway: clean-gateway protoc-go-gateway

clean:
	rm -rf ./protogen

clean-gateway:
	rm -rf ./protogen/gateway
	mkdir -p ./protogen/gateway/go
	mkdir -p ./protogen/gateway/openapiv2

protoc-go-gateway:
	protoc -I . \
		--grpc-gateway_out ./protogen/gateway/go \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--grpc-gateway_opt grpc_api_configuration=./grpc-gateway/config.yaml \
		--grpc-gateway_opt standalone=true \
		--grpc-gateway_opt generate_unbound_methods=true \
		./proto/hello/*.proto \
		./proto/bank/*.proto \
		./proto/bank/type/*.proto \
		./proto/resiliency/*.proto

protoc-openapiv2-gateway:
	protoc -I . \
		--openapiv2_out ./protogen/gateway/openapiv2 \
		--openapiv2_opt logtostderr=true \
		--openapiv2_opt output_format=yaml \
		--openapiv2_opt grpc_api_configuration=./grpc-gateway/config.yaml \
		--openapiv2_opt allow_merge=true \
		--openapiv2_opt generate_unbound_methods=true \
		--openapiv2_opt merge_file_name=merged \
		./proto/hello/*.proto \
		./proto/bank/*.proto \
		./proto/bank/type/*.proto \
		./proto/resiliency/*.proto


protoc:
	protoc --go_opt=module=$(GO_MODULE) \
		--go_out=. \
		--go-grpc_opt=module=$(GO_MODULE) \
		--go-grpc_out=. \
		./proto/hello/*.proto \
		./proto/bank/*.proto \
		./proto/bank/type/*.proto \
		./proto/payment/*.proto \
		./proto/transaction/*.proto \
		./proto/resiliency/*.proto

pipeline-init:
	sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

pipeline-build: pipeline-init build

pipeline-init-gateway:
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest

pipeline-build-gateway: pipeline-init-gateway build-gateway protoc-openapiv2-gateway

