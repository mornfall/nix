ifeq ($(MAKECMDGOALS), dist)
    ifeq ($(wildcard .git),)
      dist-files += README config/ tests/ Makefile Makefile.config.in mk/ doc/ \
	  corepkgs/ misc/ \
          $(shell find scripts/ -name \*.in -or -name \*.pl -or -name \*.sh) \
          $(shell find perl/ -name \*.pm -or -name \*.xs -or -name \*.in) \
          $(shell find -name local.mk) \
          $(shell for s in hh cc l y h c hpp sql sdf xsl js css; do find src -name \*.$$s; done)
    else
        dist-files += $(shell git ls-files)
    endif
endif
 
dist-files += configure config.h.in nix.spec

GLOBAL_CXXFLAGS += -I . -I src -I src/libutil -I src/libstore -I src/libmain -I src/libexpr

$(foreach i, config.h $(call rwildcard, src/lib*, *.hh), $(eval $(call install-file-in, $(i), $(includedir)/nix, 0644)))

$(foreach i, config.h $(call rwildcard, src/boost, *.hpp), $(eval $(call install-file-in, $(i), $(includedir)/nix/$(patsubst src/%/,%,$(dir $(i))), 0644)))
