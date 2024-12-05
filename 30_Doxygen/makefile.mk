CURDIR_WIN = $(subst /,\,$(realpath .\))
 
export PROJECTDIR=$(CURDIR_WIN)

build:
	@$(MAKE) subdirs TARGET=build -f makefile.mk
	
clean:
	@$(MAKE) subdirs TARGET=clean -f makefile.mk
	
rebuild: clean build ;

obj2srec:
	@$(MAKE) subdirs TARGET=obj2srec -f makefile.mk
	
obj2srecall: obj2srec ;

subdirs: $(SUBDIRS) ;

$(SUBDIRS):
	@$(MAKE) -C $@\reloc -I $(CURDIR) -f ..\makefile.target -j 4 $(TARGET)
	
ccm:
	@..\tools\ccm\CCM.exe ccm.config > _tmp_ccm.xml
	@echo @echo off >_tmp_ccm_patch.cmd
	@echo perl -p -e "s/\s+$$/ /g" _tmp_ccm.xml ^| perl -p -e "s|</metric>|</metric>\r\n|g" ^> ccm.xml >>_tmp_ccm_patch.cmd
	@call _tmp_ccm_patch.cmd
	@..\tools\unix-utils\egrep\ -w "ccm|complex" ccm.xml > ccm_high.xml
	@cmd /c "IF EXIST _tmp_ccm.xml (del /q _tmp_ccm.xml)"
	@cmd /c "IF EXIST _tmp_ccm_patch.cmd (del /q _tmp_ccm_patch.cmd)"
	
doxymod:
	@tools\doxygen\doxygen DoxyConfig
	@cmd /c "cd __doxydoc\latex\ && make.bat"
	copy __doxydoc\latex\refman.pdf __doxydoc\GOS2022.pdf
	
.PHONY: all build clean ccm doxygen doxyall doxyconf obj2srec obj2srecall subdirs $(SUBDIRS)

.NOTPARALLEL: subdirs $(SUBDIRS)