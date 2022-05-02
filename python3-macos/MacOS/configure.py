#!/usr/bin/env python3
import os

from util import ARCHITECTURES, env_vars, parse_args

def main():
    args, remaining = parse_args()
    os.environ.update(env_vars(args.target_arch_name))

    cmd = [
        'bash', 
            './configure',
            '--enable-shared',
            ' '.join(ARCHITECTURES[args.target_arch_name].CONF_ARGS)
    ]  

    os.execvp('bash', cmd + remaining)

if __name__ == '__main__':
    main()
