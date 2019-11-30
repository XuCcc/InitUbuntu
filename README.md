<h1 align="center">Init Ubuntu</h1>

![](https://github.com/XuCcc/InitUbuntu/workflows/CI/badge.svg)
![](https://img.shields.io/badge/platform-ubuntu%2016.04%7C18.04-lightgrey)

![](.images/show.png)

## Requires

- `git&curl&sed` You can install them easily by `bash InitUbuntu.sh --basic`
- `zsh` InitUbuntu will write env variables into ~/.zshrc. You can install `zsh` by `bash InitUbuntu.sh terminal zsh`

*Optional*

- zsh theme like `agnoster` needs [powerline fonts](https://github.com/powerline/fonts)

## Support Os

Now,InitUbuntu supports Ubuntu **16.04,18.04**.[Github actions](https://github.com/XuCcc/InitUbuntu/actions?query=workflow%3ACI) will check **16.04|18.04** every time.Some tools maybe install unsuccessfully on other version.Welcome to [issues](https://github.com/XuCcc/InitUbuntu/issues/5).

InitUbuntu maybe work well on Debian-based systems,because they use `apt` as package manager.

## Tools

Use `bash InitUbuntu.sh -h` to see support tools and help.

```bash
[update]
[source]
        apt:    http://mirrors.ustc.edu.cn/ubuntu/
        pip:    https://pypi.tuna.tsinghua.edu.cn/simple
        docker: https://docker.mirrors.ustc.edu.cn
[common]
        aira2: A lightweight multi-protocol & multi-source command-line download utility
        tldr: Simplified and community-driven man pages
        ag: A code-searching tool similar to ack, but faster.
        fd: A simple, fast and user-friendly alternative to 'find'
[python]
        pip: pip3
        pyenv: Simple Python version management
        pipenv: Python Development Workflow for Humans
        ptpython: an advanced Python REPL
[java]
        jdk: Oracle JDK
        maven: A software project management and comprehension tool
[javascript]
        nvm: Node Version Manager - Simple bash script to manage multiple active node.js versions
[docker]
        docker-ce:
        docker-compose: A tool for defining and running multi-container Docker applications
[terminal]
        zsh: a delightful, open source, community-driven framework for managing your Zsh configuration.
        zshrc: custom ~/.zshrc
        zsh-syntax-highlighting: Fish shell like syntax highlighting for Zsh
        autojump: shell extension to jump to frequently used directories
        tmux: terminal multiplexer
        tmux.conf: custom ~/.tmux.conf
```

You can find **zsh&&tmux** profiles in `./config`

> Submit any other useful develop tools in the issue.
