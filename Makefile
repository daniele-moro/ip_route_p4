CURRENT_DIR := $(shell pwd)

P4C_IMAGE := opennetworking/p4c:stable-20220112
MNSTRATUM_IMAGE := opennetworking/mn-stratum:latest

build-p4:
	$(info *** Building P4 program...)
	@mkdir -p p4c-out
	docker run --rm -v $(CURRENT_DIR):/workdir -w /workdir opennetworking/p4c:stable-20220112 \
		p4c-bm2-ss --arch v1model -o p4c-out/bmv2.json \
		--p4runtime-files p4c-out/p4info.txt,p4c-out/p4info.bin \
		--Wdisable=unsupported \
		./ip_route.p4
	@echo "*** P4 program compiled successfully! Output files are in p4c-out"

up:
	docker-compose up -d

down:
	docker-compose down

p4rt-shell:
	docker-compose run p4runtime-shell \
		--grpc-addr mininet:50001 -v \
		--device-id 1 --election-id 0,1 --config /ip_route/p4c-out/p4info.txt,/ip_route/p4c-out/bmv2.json

switch-log:
	docker-compose exec mininet tail -f /tmp/s1/stratum_bmv2.log

mn-cli:
	@echo "Detach with CTRL+D"
	@docker attach --detach-keys "ctrl-d" ip_route_p4_mininet_1
