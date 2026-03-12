BUILD_DIR?=build
MESEN_DIR?=~/Descargas/Mesen_2.1.1_Windows
all: ${BUILD_DIR}/main.nes

${BUILD_DIR}/main.nes: ${BUILD_DIR}/main.o
	ld65 -o ${BUILD_DIR}/main.nes -C cfg/example.cfg ${BUILD_DIR}/main.o -m ${BUILD_DIR}/main.map.txt -Ln ${BUILD_DIR}/main.labels.txt --dbgfile ${BUILD_DIR}/main.dbg
${BUILD_DIR}/main.o: ${BUILD_DIR} main.s
	ca65 -o ${BUILD_DIR}/main.o main.s
${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}
run: ${BUILD_DIR}/main.nes
	
	wine $(MESEN_DIR)/Mesen.exe Z:\\home\\victor\\development\\makeclassicgames\\nes\\game1\\${BUILD_DIR}\\main.nes
run_unix:
	~/Descargas/Mesen_2.1.1_Linux_x64/Mesen main.nes
clean:
	rm -Rf ${BUILD_DIR}