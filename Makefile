GO_MODULE=github.com/OleksUMD/proto-example

.PHONY: clean protoc build tidy run pipeline-build pipeline-init

run:
	go run .

tidy:
	go mod tidy

build: clean protoc tidy

clean:
	rm -rf ./protogen

protoc:
	protoc --go_opt=module=$(GO_MODULE) \
		--go_out=. \
		--go-grpc_opt=module=$(GO_MODULE) \
		--go-grpc_out=. \
		./proto/hello/*.proto \
		./proto/bank/*.proto \
		./proto/bank/type/*.proto \
		./proto/payment/*.proto \
		./proto/transaction/*.proto

pipeline-init:
	sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

pipeline-build: pipeline-init build

