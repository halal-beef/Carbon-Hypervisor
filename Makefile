ARCH = arm64
CROSS = aarch64-linux-gnu

CC      = clang --target=$(CROSS)
OBJCOPY = llvm-objcopy

CFLAGS  = -ffreestanding -Oz -flto -g -fno-pic -fno-pie -Iinclude
LDFLAGS = -nostdlib -nostartfiles -static -fuse-ld=lld -Wl,--build-id=none

OBJS = arch/$(ARCH)/start.o arch/$(ARCH)/helper.o psci.o psci_trampoline.o

# helpers for Kbuild, taken from Linux
include Makefile.kbuild
ifndef mixed-build
ifndef config-build
# end of helpers for Kbuild

export CC AS
export KBUILD_CFLAGS := $(CFLAGS)
export KBUILD_AFLAGS := $(ASFLAGS)

all: hyp.elf hyp.bin

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

hyp.elf: $(OBJS) built-in.a
	$(CC) $(CFLAGS) $(LDFLAGS) -T arch/$(ARCH)/linker.ld $(OBJS) built-in.a -o $@

hyp.bin: hyp.elf
	$(OBJCOPY) -O binary $< $@

PHONY += built-in.a
built-in.a: $(build-dir)

PHONY += $(build-dir)
$(build-dir):
	$(Q)$(MAKE) $(build)=$@ need-builtin=1 need-modorder=1 $(single-goals)

CLEAN_FILES += hyp.bin hyp.elf

MRPROPER_FILES += include/config include/generated \
		  .config .config.old

mrproper-dirs      := $(addprefix _mrproper_,scripts)

PHONY += $(mrproper-dirs) mrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

mrproper: clean $(mrproper-dirs)
	$(call cmd,rmfiles)

clean: private rm-files := $(CLEAN_FILES)
mrproper: private rm-files := $(MRPROPER_FILES)

clean-dirs := $(addprefix _clean_, $(clean-dirs))
PHONY += $(clean-dirs) clean
$(clean-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _clean_%,%,$@)

clean: $(clean-dirs)
	$(call cmd,rmfiles)
	@find . $(RCS_FIND_IGNORE) \
		\( -name '*.[oad]' -o -name '.*.cmd' \
		   -o -name '*.lex.c' -o -name '*.tab.[ch]' \
		\) -type f -print \
		| xargs rm -rf

.PHONY: clean

quiet_cmd_rmfiles = $(if $(wildcard $(rm-files)),CLEAN   $(wildcard $(rm-files)))
      cmd_rmfiles = rm -rf $(rm-files)

endif # config-build
endif # mixed-build

PHONY += FORCE
FORCE:

.PHONY: $(PHONY)

