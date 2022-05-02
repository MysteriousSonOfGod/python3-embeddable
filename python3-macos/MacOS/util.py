import argparse
import os
import pathlib
from dataclasses import dataclass
from typing import Dict, Optional

BASE = pathlib.Path(__file__).resolve().parent
SYSROOT = BASE / 'sysroot'


@dataclass
class Arch:
    MACOS_TARGET: str
    CONF_PLAT_FLAGS: Optional[list] = None

    @property
    def binutils_prefix(self) -> str:
        return self.BINUTILS_PREFIX or self.ANDROID_TARGET


ARCHITECTURES = {   
    'universal2': Arch('universal2', ['--enable-universalsdk', '--with-universal-archs=universal2']),
    'x86_64': Arch('x86_64',),
}

def env_vars(target_arch_name: str) -> Dict[str, str]:  
    env = {
        # Compiler flags
        'CPPFLAGS': f'-I{SYSROOT}/usr/include',
        'LDFLAGS': f'-L{SYSROOT}/usr/lib',

        # pkg-config settings
        'PKG_CONFIG_SYSROOT_DIR': str(SYSROOT),
        'PKG_CONFIG_LIBDIR': str(SYSROOT / 'usr' / 'lib' / 'pkgconfig'),

        'PYTHONPATH': str(BASE),
    }

    return env


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--arch', required=True, choices=ARCHITECTURES.keys(), dest='target_arch_name')
    return parser.parse_known_args()
