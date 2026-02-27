BUILD_DIR?=build
MESEN_DIR?=~/Descargas/Mesen_2.1.1_Windows
all: ${BUILD_DIR}/example.nes

${BUILD_DIR}/example.nes: ${BUILD_DIR}/example.o
	ld65 -o ${BUILD_DIR}/example.nes -C cfg/example.cfg ${BUILD_DIR}/example.o -m ${BUILD_DIR}/example.map.txt -Ln ${BUILD_DIR}/example.labels.txt --dbgfile ${BUILD_DIR}/example.dbg
${BUILD_DIR}/example.o: ${BUILD_DIR} example.s
	ca65 -o ${BUILD_DIR}/example.o example.s
${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}
run: ${BUILD_DIR}/example.nes
	
	wine $(MESEN_DIR)/Mesen.exe Z:\\home\\victor\\development\\makeclassicgames\\nes\\game1\\${BUILD_DIR}\\example.nes
run_unix:
	~/Descargas/Mesen_2.1.1_Linux_x64/Mesen example.nes
clean:
	rm -Rf ${BUILD_DIR}