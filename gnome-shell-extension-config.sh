#!/bin/bash
# ==============================================================================
# 脚本名称: setup.sh
# 功能描述：Fedora 工作站自动化初始化、优化及开发环境配置脚本
# 适用系统：Fedora Workstation 40+ (兼容 DNF 4/5)
# 作者：龙茶清欢 (优化版)
# 版本：2.0.0
# 使用方法：chmod +x setup.sh && ./setup.sh
# (请勿直接使用 sudo 运行此脚本，脚本内部会自动提权需要 root 的操作)
# 仓库克隆：cd ~/下载 && git clone --depth=1 https://gitee.com/lcqh2635/linux-setup.git
# 	cd ~/文档 && git clone --depth=1 git@gitee.com:lcqh2635/linux-setup.git
# 仓库提交：cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push
# ==============================================================================

# ------------------------------------------------------------------------------
# 安全与规范设置
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
# ------------------------------------------------------------------------------
set -euo pipefail

# gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
# gsettings list-schemas
# gsettings list-schemas | grep 'org.gnome.shell.extensions'
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences
# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# 列出所有用户级扩展
# gnome-extensions list --user
# 查看所有用户级扩展的文件目录
# nautilus ~/.local/share/gnome-shell/extensions
# ------------------------------------------------------------------------------
# 模块 1: 系统基础配置 (GNOME Settings)
# ------------------------------------------------------------------------------
configure_basics_gsettings() {
    log_info "正在配置 GNOME 桌面基础设置..."
    cd ~/下载

    # 显示登出菜单
    gsettings set org.gnome.shell always-show-log-out true
    # 设置强调色为蓝色
    gsettings set org.gnome.desktop.interface accent-color 'blue'
    # 设置新窗口居中显示
    gsettings set org.gnome.mutter center-new-windows true
    # 显示星期几
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    # 自动设置时区
    gsettings set org.gnome.desktop.datetime automatic-timezone true
    # 设置电量百分比
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    # 设置夜灯温度（色温，范围 1000~10000，默认约 2700 色温严重偏黄，越小越黄）
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
    # 开启夜灯
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    # 设置窗口按钮位置 (右)
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    # 禁用动态工作区
    gsettings set org.gnome.mutter dynamic-workspaces false
    # 设置工作区数量为3（奇数确保有中间位）
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 3
    # 预设工作区名称
    gsettings set org.gnome.desktop.wm.preferences workspace-names "['工作/代码', '浏览/文档', '娱乐/交流']"
    # 屏幕时间限制
    gsettings set org.gnome.desktop.screen-time-limits daily-limit-enabled true
    # 每日限制使用时长，从默认的 8 小时改为 10 小时
    gsettings set org.gnome.desktop.screen-time-limits daily-limit-seconds 36000
    # 桌面健康
    gsettings set org.gnome.desktop.break-reminders selected-breaks "['eyesight', 'movement']"
    # gsettings list-recursively org.gnome.desktop.break-reminders.movement
    # 半个小时活动3分钟
    gsettings set org.gnome.desktop.break-reminders.movement duration-seconds 180
    gsettings set org.gnome.desktop.break-reminders.movement interval-seconds 1800
    # 一个小时活动5分钟
    # gsettings set org.gnome.desktop.break-reminders.movement duration-seconds 300
    # gsettings set org.gnome.desktop.break-reminders.movement interval-seconds 3600
    # 隐私与安全
    gsettings set org.gnome.system.location enabled false
    gsettings set org.gnome.desktop.privacy disable-camera true
    gsettings set org.gnome.desktop.privacy disable-microphone true

    # Nautilus 设置
    # gsettings list-recursively org.gnome.nautilus.preferences
    gsettings set org.gnome.nautilus.preferences date-time-format 'detailed'
    gsettings set org.gnome.nautilus.preferences default-sort-order 'type'
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    gsettings set org.gnome.nautilus.preferences show-delete-permanently true
    
    gsettings set org.gnome.Ptyxis interface-style 'system'
    gsettings set org.gnome.shell.weather automatic-location true
    # 设置天气位置
    gsettings set org.gnome.Weather locations "[<(uint32 2, <('Shenzhen', 'ZGSZ', false, [(0.39357174632472131, 1.9914206765255298)], @a(dd) [])>)>]"

    # 快捷键优化
    log_info "配置自定义快捷键..."
    # 自定义快捷键优化，Alt 管理工作区、Super 管理窗口
    # gsettings list-recursively org.gnome.desktop.wm.keybindings
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "['<Alt>End']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>1']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>2']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>3']"
    # 切换当前工作区所有的窗口的显示与隐藏，可以替代 Show Desktop Button 扩展插件的功能
    gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>Home']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"
    # gsettings set org.gnome.desktop.wm.keybindings move-to-center "['<Super>Right']"
    # Alt + Super 移动当前工作取得窗口到左右其他工作区
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Alt>Left']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Alt>Right']"
    # gsettings list-recursively org.gnome.shell.keybindings

    if [ ! -d "$HOME/下载/linux-setup" ]; then
        git config --global user.name "lcqh2635"
        git config --global user.email "lcqh2635@gmail.com"
        git clone --depth=1 https://gitee.com/lcqh2635/linux-setup.git
        cp -r ~/下载/linux-setup/template/* /home/lcqh/模板/
        mkdir -vp ~/.local/share/backgrounds
        # nautilus ~/.local/share/backgrounds/
        # nautilus admin:/usr/share/backgrounds/
        cp -r ~/下载/linux-setup/wallpaper/* ~/.local/share/backgrounds/
        # gsettings list-recursively org.gnome.desktop.background
        gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"
    fi
    
    # 甚至可以使用大括号展开来创建有规律的目录
    mkdir -vp $HOME/编程/{Java,Rust,Cpp,Python,TypeScript,Database,Gnome}
    mkdir -vp $HOME/编程/Database/{SQLite,MySQL,MariaDB,Postgres,Distributed,Redis}
    
    log_success "GNOME 基础配置完成。"
}

# 安装 gnome shell 扩展插件
install_gnome_extensions() {
    # ------------------------------------------------------------------------------
    # dnf list gnome-shell-extension*
    # gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
    # gsettings list-schemas
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # gsettings list-recursively org.gnome.desktop.interface
    # gsettings list-recursively org.gnome.desktop.wm.preferences
    # 列出所有系统级扩展
    # gnome-extensions list --system
    # 查看所有系统级扩展的文件目录
    # nautilus admin:/usr/share/gnome-shell/extensions
    sudo dnf remove -y \
    gnome-shell-extension-window-list \
    gnome-shell-extension-launch-new-instance
    sudo dnf install -y \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-auto-move-windows \
    gnome-shell-extension-background-logo \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-forge \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-just-perfection \
    gnome-shell-extension-light-style \
    gnome-shell-extension-drive-menu \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-workspace-indicator
    
    # https://github.com/lcqh2635/gnome-shell-extensions
    sudo dnf copr enable lcqh2635/gnome-shell-extensions
    # ls /etc/yum.repos.d && cat /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:lcqh2635:gnome-shell-extensions.repo
    sudo dnf install -y \
    gnome-shell-extension-add-to-desktop.noarch \
    gnome-shell-extension-alphabetical-grid.noarch \
    gnome-shell-extension-appmenu-is-back.noarch \
    gnome-shell-extension-clipboard-indicator.noarch \
    gnome-shell-extension-compiz-magic.noarch \
    gnome-shell-extension-coverflow-alt-tab.noarch \
    gnome-shell-extension-customize-ibus.noarch \
    gnome-shell-extension-ddterm.noarch \
    gnome-shell-extension-desktop-icons-ng.noarch \
    gnome-shell-extension-disable-unredirect.noarch \
    gnome-shell-extension-hide-top-bar.noarch \
    gnome-shell-extension-night-theme-switcher.noarch \
    gnome-shell-extension-quick-settings-tweaks.noarch \
    gnome-shell-extension-rounded-screen-corners.noarch \
    gnome-shell-extension-rounded-window-corners.noarch \
    gnome-shell-extension-screencast-extra-feature.noarch \
    gnome-shell-extension-search-light.noarch \
    gnome-shell-extension-status-area-horizontal-spacing.noarch \
    gnome-shell-extension-top-bar-organizer.noarch \
    gnome-shell-extension-vitals.noarch \
    gnome-shell-extension-weather-oclock.noarch
    
    # Auto Move Windows
    # gsettings list-recursively org.gnome.shell.extensions.auto-move-windows
    gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['jetbrains-toolbox.desktop:1', 'jetbrains-idea-62993215-707e-404d-9a7c-b2e595f35fa6.desktop:1', 'jetbrains-rustrover-150f2c1b-2bd9-4306-97e7-2bc711731347.desktop:1', 'jetbrains-webstorm-438e488a-1597-484e-b6ea-e9935bebb250.desktop:1', 'jetbrains-goland-d6242613-2f2e-4847-a243-19dc05529fca.desktop:1', 'jetbrains-datagrip-d81f105e-144e-4ef3-943d-1171bda2c629.desktop:1', 'jetbrains-pycharm-c8b885ec-b50e-4a8a-9408-cba329de5d43.desktop:1', 'jetbrains-studio-1a3645b2-82e4-4794-b038-c5c084909e0d.desktop:1', 'com.sublimehq.SublimeText.desktop:1', 'org.gnome.Ptyxis.desktop:1', 're.sonny.Playhouse.desktop:1', 'me.iepure.devtoolbox.desktop:1', 'io.github.mightycreak.Diffuse.desktop:1', 'com.github.marhkb.Pods.desktop:1', 'dev.skynomads.Seabird.desktop:1', 'qemu.desktop:1', 'org.gnome.Builder.desktop:1', 'org.gnome.SystemMonitor.desktop:1', 'org.mozilla.firefox.desktop:2', 'com.google.Chrome.desktop:2', 'org.gnome.Epiphany.desktop:2', 'org.gnome.TextEditor.desktop:2', 'io.github.alainm23.planify.desktop:2', 'org.gnome.gitlab.somas.Apostrophe.desktop:2', 'Clash Verge.desktop:2', 'v2rayn.desktop:2', 'md.obsidian.Obsidian.desktop:2', 'io.typora.Typora.desktop:2', 'org.gnome.Papers.desktop:2', 'com.qq.QQ.desktop:3', 'com.github.gmg137.netease-cloud-music-gtk.desktop:3', 'com.github.neithern.g4music.desktop:3']"
    # gsettings reset-recursively org.gnome.shell.extensions.auto-move-windows

    # Background Logo
    # gsettings list-recursively org.fedorahosted.background-logo-extension
    gsettings set org.fedorahosted.background-logo-extension logo-always-visible true
    # gsettings reset-recursively org.fedorahosted.background-logo-extension
    
    # Blur My Shell
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell
    # gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell
    # 1、管线		以下配置是 ‘管线’ 这个菜单项下面的配置内容
    # gsettings get org.gnome.shell.extensions.blur-my-shell pipelines
    # gsettings reset org.gnome.shell.extensions.blur-my-shell pipelines
    # gsettings set org.gnome.shell.extensions.blur-my-shell pipelines "{'pipeline-overview': {'name': <'pipeline overview'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_24286504481826'>, 'params': <@a{sv} {}>}>]>}, 'pipeline-panel-light': {'name': <'pipeline panel light'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <1>, 'unscaled_radius': <100>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <24>, 'corners_bottom': <false>}>}>, <{'type': <'color'>, 'id': <'effect_11444492989407'>, 'params': <{'color': <(1.0, 1.0, 1.0, 0.20000000000000001)>}>}>, <{'type': <'noise'>, 'id': <'effect_65216760835902'>, 'params': <@a{sv} {}>}>]>}, 'pipeline-panel-dark': {'name': <'pipeline panel dark'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_34582829524533'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_01633318478434'>, 'params': <{'corners_bottom': <false>, 'radius': <24>}>}>, <{'type': <'color'>, 'id': <'effect_61396509891604'>, 'params': <{'color': <(0.0, 0.0, 0.0, 0.20000000000000001)>}>}>, <{'type': <'noise'>, 'id': <'effect_05167466921904'>, 'params': <@a{sv} {}>}>]>}, 'pipeline-dock-light': {'name': <'pipeline dock light'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_69102858487382'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_89248773469157'>, 'params': <{'radius': <24>, 'corners_bottom': <true>}>}>]>}, 'pipeline-dock-dark': {'name': <'pipeline dock dark'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_63269999366132'>, 'params': <{'brightness': <1>, 'unscaled_radius': <100>}>}>, <{'type': <'corner'>, 'id': <'effect_88027249213595'>, 'params': <{'radius': <24>}>}>]>}}"
    # gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline-panel-light'
    # gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline-overview'
    # gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline-dock-light'
    # 2、面板		以下配置是 ‘面板’ 这个菜单项下面的配置内容
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.panel
    # gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell.panel
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
    gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
    # 3、概览		以下配置是 ‘概览’ 这个菜单项下面的配置内容
    gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
    # 4、任务栏		以下配置是 ‘任务栏’ 这个菜单项下面的配置内容
    gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1
    
    # 5、应用程序	以下配置是 ‘应用程序’ 这个菜单项下面的配置内容
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.applications
    # gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell.applications
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur true
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications sigma 50
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications brightness 1.0
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications opacity 255
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications dynamic-opacity false
    # gsettings set org.gnome.shell.extensions.blur-my-shell.applications whitelist "['org.gnome.Settings', 'org.gnome.Nautilus', 'org.gnome.Software', 'org.gnome.TextEditor', 'org.gnome.Ptyxis', 'org.gnome.SystemMonitor', 'org.gnome.tweaks', 'org.gnome.Extensions', 'org.gnome.Shell.Extensions', 'org.gnome.SystemMonitor', 'org.gnome.Yelp', 'org.gnome.Tour', 'org.gnome.Maps', 'org.gnome.Gtranslator', 'org.gnome.Firmware', 'org.gnome.Calculator', 'org.gnome.Contacts', 'org.gnome.Calendar', 'org.gnome.clocks', 'org.gnome.Loupe', 'org.gnome.Papers', 'org.gnome.Decibels', 'org.gnome.font-viewer', 'org.gnome.Showtime', 'org.gnome.Weather', 'org.gnome.Builder', 'org.gnome.SimpleScan', 'org.gnome.Characters', 'org.gnome.baobab', 'org.gnome.Logs', 'org.gnome.Snapshot', 'org.gnome.gitlab.somas.Apostrophe', 'io.github.kolunmi.Bazaar', 'io.github.giantpinkrobots.flatsweep', 'io.github.realmazharhussain.GdmSettings', 'io.gitlab.adhami3310.Impression', 'io.github.alainm23.planify', 'io.github.sitraorg.sitra', 'io.github.flattool.Warehouse', 'com.github.tchx84.Flatseal', 'com.github.neithern.g4music', 'com.github.marhkb.Pods', 'it.mijorus.gearlever', 'com.usebottles.bottles', 'com.mattjakeman.ExtensionManager', 'org.freedesktop.MalcontentControl', 're.sonny.Playhouse', 'page.tesk.Refine', 'dev.skynomads.Seabird', 'v2rayN', 'com.gitee.gmg137.NeteaseCloudMusicGtk4', 'jetbrains-toolbox', 'Timeshift-gtk']"
    # 6、其它		以下配置是 ‘其它’ 这个菜单项下面的配置内容
    gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false
    
    # Dash To Dock
    # gsettings list-recursively org.gnome.shell.extensions.dash-to-dock
    # gsettings reset-recursively org.gnome.shell.extensions.dash-to-dock
    gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.5
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
    
    # Forge
    # gsettings list-recursively org.gnome.shell.extensions.forge
    # 默认不启用窗口平铺模式
    gsettings set org.gnome.shell.extensions.forge tiling-mode-enabled false
    gsettings set org.gnome.shell.extensions.forge focus-border-toggle false
    # gsettings reset-recursively org.gnome.shell.extensions.forge
    
    # Just Perfection
    # gsettings list-recursively org.gnome.shell.extensions.just-perfection
    # gsettings set org.gnome.shell.extensions.just-perfection activities-button false
    gsettings set org.gnome.shell.extensions.just-perfection accessibility-menu false
    gsettings set org.gnome.shell.extensions.just-perfection world-clock false
    gsettings set org.gnome.shell.extensions.just-perfection weather false
    gsettings set org.gnome.shell.extensions.just-perfection events-button false
    # 概览中工作区切换区缩略图，此处设置为隐藏
    gsettings set org.gnome.shell.extensions.just-perfection workspace false
    gsettings set org.gnome.shell.extensions.just-perfection workspace-wrap-around true
    gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
    gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
    # gsettings set org.gnome.shell.extensions.just-perfection accent-color-icon false
    gsettings set org.gnome.shell.extensions.just-perfection animation 7
    # gsettings reset-recursively org.gnome.shell.extensions.just-perfection
    
    # System Monitor
    # gsettings list-recursively org.gnome.shell.extensions.system-monitor
    gsettings set org.gnome.shell.extensions.system-monitor show-memory false
    gsettings set org.gnome.shell.extensions.system-monitor show-swap false
    gsettings set org.gnome.shell.extensions.system-monitor show-upload false
    # gsettings reset-recursively org.gnome.shell.extensions.system-monitor
    
    # User Themes
    # gsettings list-recursively org.gnome.shell.extensions.user-theme
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
    # gsettings reset-recursively org.gnome.shell.extensions.user-theme
    gsettings list-recursively org.gnome.Weather
    
    # dnf list gnome-shell-extension*
    # gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
    # gsettings list-schemas
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # gsettings list-recursively org.gnome.desktop.interface
    # gsettings list-recursively org.gnome.desktop.wm.preferences
    # 列出所有用户级扩展
    # gnome-extensions list --user
    # 查看所有用户级扩展的文件目录
    # nautilus ~/.local/share/gnome-shell/extensions
    if [ -d "$HOME/下载/extensions" ]; then
        rm -rf "$HOME/下载/extensions"
    fi
    if [ ! -d "$HOME/下载/extensions" ]; then
        sudo dnf install -y gettext meson just
        mkdir -p ~/下载/extensions && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/lcqh2635/linux-setup.git
        cd ~/下载/extensions/add-to-desktop && ./build.sh && gnome-extensions install -f output/add-to-desktop@tommimon.github.com.*.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/stuarthayhurst/alphabetical-grid-extension.git
        cd ~/下载/extensions/alphabetical-grid-extension && make build && make install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/fthx/appmenu-is-back.git
        cd ~/下载/extensions && zip -FSr appmenu-is-back.zip appmenu-is-back/* && gnome-extensions install -f appmenu-is-back.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/ionutbortis/gnome-bedtime-mode.git
        cd ~/下载/extensions/gnome-bedtime-mode && ./scripts/install.sh && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/maniacx/Bluetooth-Battery-Meter.git
        cd ~/下载/extensions/Bluetooth-Battery-Meter && ./install.sh && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git
        cd ~/下载/extensions/gnome-shell-extension-clipboard-indicator && make bundle && gnome-extensions install -f bundle.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/hermes83/compiz-alike-magic-lamp-effect.git
        cd ~/下载/extensions/compiz-alike-magic-lamp-effect && ./zip.sh && gnome-extensions install -f compiz-alike-magic-lamp-effect@hermes83.github.com.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/dsheeler/CoverflowAltTab.git
        cd ~/下载/extensions/CoverflowAltTab && make all && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/StorageB/custom-command-menu.git
        cd ~/下载/extensions && zip -FSr custom-command-menu.zip custom-command-menu/* && gnome-extensions install -f custom-command-menu.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/openSUSE/Customize-IBus.git
        cd ~/下载/extensions/Customize-IBus && make install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/ddterm/gnome-shell-extension-ddterm.git
        cd ~/下载/extensions/gnome-shell-extension-ddterm && meson setup build-dir && ninja -C build-dir bundle && ninja -C build-dir user-install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/Exeos/disable-unredirect.git
        cd ~/下载/extensions/disable-unredirect && make zip && gnome-extensions install -f extension.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/marcinjahn/gnome-do-not-disturb-while-screen-sharing-or-recording-extension.git
        cd ~/下载/extensions/gnome-do-not-disturb-while-screen-sharing-or-recording-extension && npm i && npm run build && npm run linkdist && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/purejava/fedora-update.git
        cd ~/下载/extensions && zip -FSr fedora-update.zip fedora-update/* && gnome-extensions install -f fedora-update.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/Schneegans/Fly-Pie.git
        cd ~/下载/extensions/Fly-Pie && make install && cd ~/下载/extensions
        git clone --depth=1 https://gitlab.com/Czarlie/gnome-fuzzy-app-search.git
        cd ~/下载/extensions/gnome-fuzzy-app-search && make install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/gTile/gTile.git
        cd ~/下载/extensions/gTile && npm ci && npm run build:dist && npm run install:extension && cd ~/下载/extensions
        git clone --depth=1 https://gitlab.com/smedius/desktop-icons-ng.git
        cd ~/下载/extensions/desktop-icons-ng && ./scripts/local_install.sh && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/tuxor1337/hidetopbar.git
        cd ~/下载/extensions/hidetopbar && make && gnome-extensions install -f hidetopbar.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/Aryan20/Logomenu.git
        cd ~/下载/extensions/Logomenu && make install && cd ~/下载/extensions
        git clone --depth=1 https://gitlab.com/rmnvgr/nightthemeswitcher-gnome-shell-extension.git
        cd ~/下载/extensions/nightthemeswitcher-gnome-shell-extension && meson setup builddir --prefix=~/.local && meson install -C builddir && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/paperwm/PaperWM.git
        cd ~/下载/extensions/PaperWM && make install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/stuarthayhurst/privacy-menu-extension.git
        cd ~/下载/extensions/privacy-menu-extension && make build && make install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/d-go/quick-settings-avatar.git
        cd ~/下载/extensions && zip -FSr quick-settings-avatar.zip quick-settings-avatar/* && gnome-extensions install -f quick-settings-avatar.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/qwreey/quick-settings-tweaks.git
        cd ~/下载/extensions/quick-settings-tweaks && npm i && TARGET=dev ./install.sh create-release && gnome-extensions install -f target/quick-settings-tweaks@qwreey.shell-extension.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/lennart-k/gnome-rounded-corners.git
        cd ~/下载/extensions/gnome-rounded-corners && make && gnome-extensions install -f Rounded_Corners@lennart-k.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/flexagoon/rounded-window-corners.git
        cd ~/下载/extensions/rounded-window-corners && just install && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/WSID/gnome-shell-screencast-extra-feature.git
        cd ~/下载/extensions/gnome-shell-screencast-extra-feature && ./build.sh && gnome-extensions install -f screencast.extra.feature@wissle.me.shell-extension.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/icedman/search-light.git
        cd ~/下载/extensions/search-light && make && cd ~/下载/extensions
        git clone --depth=1 https://gitlab.com/p91paul/status-area-horizontal-spacing-gnome-shell-extension.git
        cd ~/下载/extensions/status-area-horizontal-spacing-gnome-shell-extension && ./buildforupload.sh && gnome-extensions install -f status-area-horizontal-spacing@mathematical.coffee.gmail.com.zip && cd ~/下载/extensions
        git clone --depth=1 https://gitlab.gnome.org/june/top-bar-organizer.git
        cd ~/下载/extensions/top-bar-organizer && npm i && ./package.sh && gnome-extensions install -f top-bar-organizer@julian.gse.jsts.xyz.shell-extension.zip && cd ~/下载/extensions
        git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/CleoMenezesJr/weather-oclock.git
        cd ~/下载/extensions/weather-oclock && make install && cd ~/下载/extensions
        
        cd ~/下载
        # 解决用户 Gnome 扩展无法使用 gsettings 的问题
        for EXT_DIR in ~/.local/share/gnome-shell/extensions/*/; do
            EXT_ID=$(basename "$EXT_DIR")
            echo "处理扩展: $EXT_ID"
            if [ -d "$EXT_DIR/schemas" ]; then
                glib-compile-schemas "$EXT_DIR/schemas"
                mkdir -p ~/.local/share/glib-2.0/schemas/
                cp "$EXT_DIR/schemas"/*.xml ~/.local/share/glib-2.0/schemas/
            fi
        done
        glib-compile-schemas ~/.local/share/glib-2.0/schemas/
        # 删除临时文件夹
        rm -rf ~/下载/extensions
        
        # Bedtime Mode
        # gsettings list-recursively org.gnome.shell.extensions.bedtime-mode
        gsettings set org.gnome.shell.extensions.bedtime-mode automatic-schedule true
        gsettings set org.gnome.shell.extensions.bedtime-mode schedule-start-hours 23
        gsettings set org.gnome.shell.extensions.bedtime-mode schedule-end-hours 8
        gsettings set org.gnome.shell.extensions.bedtime-mode ondemand-button-visibility 'active-schedule'
        # gsettings reset-recursively org.gnome.shell.extensions.bedtime-mode
        
        # Coverflow Alt-Tab
        # gsettings list-recursively org.gnome.shell.extensions.coverflowalttab
        gsettings set org.gnome.shell.extensions.coverflowalttab switcher-looping-method 'Carousel'
        gsettings set org.gnome.shell.extensions.coverflowalttab hide-panel false
        # 设置背景黯淡因素，越大越暗
        gsettings set org.gnome.shell.extensions.coverflowalttab dim-factor 0.0
        gsettings set org.gnome.shell.extensions.coverflowalttab animation-time 0.5
        # gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-quint'
        gsettings set org.gnome.shell.extensions.coverflowalttab preview-to-monitor-ratio 0.7
        # gsettings reset-recursively org.gnome.shell.extensions.coverflowalttab
        
        # Custom Command Menu
        # gsettings list-recursively org.gnome.shell.extensions.custom-command-list
        gsettings set org.gnome.shell.extensions.custom-command-list command1 "('更新系统', 'ptyxis -- /bin/sh -c \"pkexec dnf upgrade; echo Done - Press enter to exit; read _\"', 'view-refresh-symbolic', true)"
        gsettings set org.gnome.shell.extensions.custom-command-list command2 "('亮色主题', \"gsettings set org.gnome.desktop.interface color-scheme 'default'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'\", 'night-light-symbolic', true)"
        gsettings set org.gnome.shell.extensions.custom-command-list command3 "('暗色主题', \"gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'\", 'night-light-disabled-symbolic', true)"
        # gsettings reset-recursively org.gnome.shell.extensions.custom-command-list
        
        # Customize-IBus
        # gsettings list-recursively org.gnome.shell.extensions.customize-ibus
        gsettings set org.gnome.shell.extensions.customize-ibus use-input-indicator false
        gsettings set org.gnome.shell.extensions.customize-ibus input-indicator-only-on-toggle true
        gsettings set org.gnome.shell.extensions.customize-ibus use-candidate-box-right-click true
        gsettings set org.gnome.shell.extensions.customize-ibus use-popup-animation true
        gsettings set org.gnome.shell.extensions.customize-ibus enable-orientation true
        gsettings set org.gnome.shell.extensions.customize-ibus use-candidate-reposition true
        gsettings set org.gnome.shell.extensions.customize-ibus use-candidate-scroll true
        gsettings set org.gnome.shell.extensions.customize-ibus menu-ibus-preference true
        gsettings set org.gnome.shell.extensions.customize-ibus enable-auto-switch false
        # gsettings reset-recursively org.gnome.shell.extensions.customize-ibus
        
        # ddterm，默认的切换快捷键 F12
        # gsettings list-recursively com.github.amezin.ddterm
        gsettings set com.github.amezin.ddterm background-opacity 1.0
        gsettings set com.github.amezin.ddterm show-animation-duration 0.3
        gsettings set com.github.amezin.ddterm hide-animation-duration 0.2
        # gsettings set com.github.amezin.ddterm window-size 0.6
        gsettings set com.github.amezin.ddterm hide-when-focus-lost true
        gsettings set com.github.amezin.ddterm hide-window-on-esc true
        # gsettings reset-recursively com.github.amezin.ddterm
        
        # gTile
        # gsettings list-recursively org.gnome.shell.extensions.gtile
        gsettings set org.gnome.shell.extensions.gtile grid-sizes '4x4,6x4,8x6'
        # gsettings reset-recursively org.gnome.shell.extensions.gtile
        
        # Gtk4 Desktop Icons NG
        # gsettings list-recursively org.gnome.shell.extensions.gtk4-ding
        gsettings set org.gnome.shell.extensions.gtk4-ding show-home false
        gsettings set org.gnome.shell.extensions.gtk4-ding show-trash false
        gsettings set org.gnome.shell.extensions.gtk4-ding show-volumes false
        # gsettings reset-recursively org.gnome.shell.extensions.gtk4-ding
        
        # Hide Top Bar
        # gsettings list-recursively org.gnome.shell.extensions.hidetopbar
        # 设置鼠标触发灵敏度（true/false）
        gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
        gsettings set org.gnome.shell.extensions.hidetopbar animation-time-autohide 0.5
        gsettings set org.gnome.shell.extensions.hidetopbar animation-time-overview 0.5
        # 窗口被激活时不要总是显示 panel
        gsettings set org.gnome.shell.extensions.hidetopbar enable-active-window false
        # gsettings reset-recursively org.gnome.shell.extensions.hidetopbar
        
        # Logo Menu
        # gsettings list-recursively org.gnome.shell.extensions.logo-menu
        gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-image 1
        gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-size 20
        gsettings set org.gnome.shell.extensions.logo-menu show-activities-button false
        # gsettings reset-recursively org.gnome.shell.extensions.logo-menu
        
        # Night Theme Switcher
        # gsettings list-recursively org.gnome.shell.extensions.nightthemeswitcher.color-scheme
        # gsettings list-recursively org.gnome.shell.extensions.nightthemeswitcher.commands
        # gsettings list-recursively org.gnome.shell.extensions.nightthemeswitcher.time
        # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunrise
        # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunset
        gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands enabled true
        # 使用 WhiteSur-*-solid 不透明 GTK 主题版本
        # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunrise
        gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunrise "gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline-panel-light'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline-dock-light'"
        # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunset
        gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunset "gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline-panel-dark'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline-dock-dark'"
        # gsettings reset-recursively org.gnome.shell.extensions.nightthemeswitcher.commands
        
        # Quick Settings Tweaks
        # 控制 GNOME 顶部面板快捷设置菜单（Quick Settings）的弹出样式和动画效果
        # gsettings list-recursively org.gnome.shell.extensions.quick-settings-tweaks
        # 启用或禁用 覆盖式菜单样式（即快捷设置面板以独立浮层形式弹出，而非传统的下拉样式）。
        gsettings set org.gnome.shell.extensions.quick-settings-tweaks overlay-menu-enabled true
        # gsettings reset-recursively org.gnome.shell.extensions.quick-settings-tweaks
        
        # Rounded Window Corners Reborn
        # gsettings list-recursively org.gnome.shell.extensions.rounded-window-corners-reborn
        gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn global-rounded-corner-settings "{'padding': <{'left': uint32 1, 'right': 1, 'top': 1, 'bottom': 1}>, 'keepRoundedCorners': <{'maximized': false, 'fullscreen': false}>, 'borderRadius': <uint32 15>, 'smoothing': <0.5>, 'borderColor': <(0.5, 0.5, 0.5, 1.0)>, 'enabled': <true>}"
        # gsettings reset-recursively org.gnome.shell.extensions.rounded-window-corners-reborn
        
        # Search Light
        # gsettings list-recursively org.gnome.shell.extensions.search-light
        gsettings set org.gnome.shell.extensions.search-light shortcut-search "['<Super>s']"
        gsettings set org.gnome.shell.extensions.search-light border-radius 6
        gsettings set org.gnome.shell.extensions.search-light blur-background true
        # gsettings reset-recursively org.gnome.shell.extensions.search-light
        
        # Status Area Horizontal Spacing
        # gsettings list-recursively org.gnome.shell.extensions.status-area-horizontal-spacing
        gsettings set org.gnome.shell.extensions.status-area-horizontal-spacing hpadding 5
        # gsettings reset-recursively org.gnome.shell.extensions.status-area-horizontal-spacing
        
        # Top Bar Organizer
        # gsettings list-recursively org.gnome.shell.extensions.top-bar-organizer
        gsettings set org.gnome.shell.extensions.top-bar-organizer left-box-order "['LogoMenu', 'apps-menu', 'places-menu', 'command-menu', 'appmenu-indicator']"
        gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['dateMenu']"
        gsettings set org.gnome.shell.extensions.top-bar-organizer right-box-order "['system-monitor@gnome-shell-extensions.gcampax.github.com', 'workspace-indicator', 'gTile@vibou', 'FedoraUpdateIndicator', 'ddterm', 'BedtimeModeToggleButton', 'clipboardIndicator', 'drive-menu', 'screenRecording', 'screenSharing', 'dwellClick', 'a11y', 'keyboard', 'quickSettings']"
        # gsettings reset-recursively org.gnome.shell.extensions.top-bar-organizer
        
        # User Avatar In Quick Settings
        # gsettings list-recursively org.gnome.shell.extensions.quick-settings-avatar
        gsettings set org.gnome.shell.extensions.quick-settings-avatar avatar-position 1
        # gsettings reset-recursively org.gnome.shell.extensions.quick-settings-avatar
        
        # 想要彻底退出当前用户的所有程序并返回到登录屏幕（GDM）
        # 立即登出（不确认）：这会关闭所有打开的应用程序并返回到登录界面
        # gnome-session-quit --logout --no-prompt
        # 弹出确认对话框：会弹出一个图形化的确认框，询问你是否真的要登出。
        # gnome-session-quit --logout
    fi
}

set_theme_example() {
    # 启用系统 GNOME 扩展
    # AppIndicator and KStatusNotifierItem Support
    # Apps Menu
    # Auto Move Windows
    # Background Logo
    # Blur my Shell
    # Caffeine
    # Dash to Dock
    # Forge
    # GSConnect
    # Just Perfection
    # Light Style
    # No overview at start-up
    # Places Status Indicator
    # Removable Drive Menu
    # User Themes
    # Workspace Indicator
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
    gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable background-logo@fedorahosted.org
    gnome-extensions enable blur-my-shell@aunetx
    gnome-extensions enable caffeine@patapon.info
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gnome-extensions enable forge@jmmaranan.com
    gnome-extensions enable gsconnect@andyholmes.github.io
    gnome-extensions enable just-perfection-desktop@just-perfection
    gnome-extensions enable light-style@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable no-overview@fthx
    gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
    # 列出所有系统级扩展
    # gnome-extensions list --system
    # dnf list gnome-shell-extension*
    
    # 启用用户 GNOME 扩展
    # Add to Desktop
    # Alphabetical App Grid
    # App menu is back
    # Bluetooth Battery Meter
    # Clipboard Indicator
    # Compiz alike magic lamp effect
    # Coverflow Alt-Tab
    # Custom Command Menu
    # Customize IBus
    # ddterm
    # Disable Unredirect
    # Do Not Disturb While Screen Sharing Or Recording
    # Fedora Linux Update Indicator
    # Fly-Pie
    # GNOME Fuzzy App Search
    # gTile
    # Gtk4 Desktop Icons NG (DING)
    # Hide Top Bar
    # Logo Menu
    # Night Theme Switcher
    # PaperWM
    # Privacy Quick Settings
    # User Avatar In Quick Settings
    # Quick Settings Tweaks
    # Rounded Corners
    # Rounded Window Corners Reborn
    # Search Light
    # Screencast extra Feature
    # Status Area Horizontal Spacing
    # Top Bar Organizer
    # Weather O'Clock
    gnome-extensions enable add-to-desktop@tommimon.github.com
    gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
    gnome-extensions enable appmenu-is-back@fthx
    gnome-extensions enable Bluetooth-Battery-Meter@maniacx.github.com
    gnome-extensions enable clipboard-indicator@tudmotu.com
    gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com
    gnome-extensions enable CoverflowAltTab@palatis.blogspot.com
    gnome-extensions enable custom-command-list@storageb.github.com
    gnome-extensions enable customize-ibus@hollowman.ml
    gnome-extensions enable ddterm@amezin.github.com
    gnome-extensions enable disable-unredirect@exeos
    gnome-extensions enable update-extension@purejava.org
    gnome-extensions enable flypie@schneegans.github.com
    gnome-extensions enable gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com
    gnome-extensions enable gtk4-ding@smedius.gitlab.com
    gnome-extensions enable hidetopbar@mathieu.bidon.ca
    gnome-extensions enable logomenu@aryan_k
    gnome-extensions enable nightthemeswitcher@romainvigier.fr
    gnome-extensions enable PrivacyMenu@stuarthayhurst
    gnome-extensions enable quick-settings-avatar@d-go
    gnome-extensions enable quick-settings-tweaks@qwreey
    gnome-extensions enable Rounded_Corners@lennart-k
    gnome-extensions enable rounded-window-corners@fxgn
    gnome-extensions enable screencast.extra.feature@wissle.me
    gnome-extensions enable search-light@icedman.github.com
    gnome-extensions enable status-area-horizontal-spacing@mathematical.coffee.gmail.com
    gnome-extensions enable top-bar-organizer@julian.gse.jsts.xyz
    gnome-extensions enable weatheroclock@CleoMenezesJr.github.io
    # 列出所有用户级扩展
    # gnome-extensions list --user
    
    # ArcMenu
    # Vitals
    # Bedtime Mode
    # Battery Health Charging
    # Bing Wallpaper
    # Burn My Windows
    # CHC-E (Custom Hot Corners - Extended)
    # Compiz windows effect
    # In Picture
    # Lunar Calendar 农历
    # Shortcuts
    # Smart Auto Move NG
    # Kiwi Menu
    # Kiwi is not Apple
    # Open Bar
    # Dash2Dock Animated
    # Copyous
    # Media Controls
    # Focus changer
    # SoundBar
    # Brightness control using ddcutil
    # Accent Icons
    # Light/Dark cursor theme
    # Accent icons theme
    # Accent user theme
    # Accent gtk theme
    # Custom Command Toggle
    # Custom Command Menu
    # Window Desaturation
    # Live Lock Screen
    # Show Desktop Button
    # Extension List
    # Quick Settings Audio Panel
    # RebootToUEFI
    # Application Hotkeys
    # Battery Power Mode Indicator
    # Edit Desktop Files
    # Applications Overview Tooltip
    # Desktop Lyric
    
    # 这是一款专为 GNOME Shell 设计的动态壁纸扩展
    # https://github.com/jeffshee/gnome-ext-hanabi
    git clone --depth=1 https://github.com/jeffshee/gnome-ext-hanabi.git
    git clone --depth=1 https://github.com/ayasa520/gnome-ext-hanabi.git
    https://github.com/ayasa520/gnome-ext-hanabi/blob/master/docs/fedora-41.md
    cd gnome-ext-hanabi && ./run.sh install
    
    
    # gnome-extensions 直接使用可以查看扩展的所有命令的作用
    # gnome-extensions help
    # help      	打印帮助
    # version   	打印版本
    # enable    	启用扩展
    # disable   	禁用扩展
    # reset     	重置扩展
    # uninstall 	卸载扩展
    # list      	列出扩展
    # info      	显示扩展信息
    # show      	显示扩展信息
    # prefs     	打开扩展首选项
    # create    	创建扩展
    # pack      	打包扩展
    # install   	安装扩展包
    # gnome-extensions create [选项…]
    # --uuid=UUID                	新扩展的唯一标识符
    # --name=名称                			新扩展的用户可见名称
    # --description=描述         		扩展功能的简短描述
    # --gettext-domain=域        		扩展使用的 gettext 域
    # --settings-schema=架构     		扩展使用的 GSettings 方案
    # --template=模板            		新扩展使用的模板
    # --prefs                    	包括 prefs.js 模版
    # -i, --interactive          	以交互方式输入扩展信息
    # -q, --quiet                	不要打印错误信息


    git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/florintanasa/light-dark-cursor-theme.git
    git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/florintanasa/accent-icons-theme.git
    git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/florintanasa/accent-user-theme.git
    git clone --depth=1 ${GITHUB_PROXY_URL}https://github.com/florintanasa/accent-gtk-theme.git
    
    git clone --depth=1 git@github.com:lcqh2635/auto-switch-themes.git
    # git add . && git commit -m 'backup' && git push
    # Workbench 是一个具有超过一百个 GNOME 平台 JavaScript 演示的交互式工具
    flatpak install -y flathub re.sonny.Workbench
    # gnome-extensions create help
    # gsettings set org.gnome.desktop.interface accent-color 'blue'
    # GNOME Shell Extensions 开发文档			https://gjs.guide/extensions/
    # GNOME Shell Extensions metadata.json 文档		https://gjs.guide/extensions/overview/anatomy.html
    # 以交互式地开始创建扩展：
    # 新扩展已成功创建在目录 $HOME/.local/share/gnome-shell/extensions/auto-switch-themes@lcqh2635
    # nautilus admin:/usr/share/gnome-shell/extensions
    # nautilus $HOME/.local/share/gnome-shell/extensions
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # 1、创建扩展
    # https://gjs.guide/extensions/development/creating.html
    gnome-extensions create \
    --uuid="auto-switch-themes@lcqh2635.github.com" \
    --name="Auto Switch Themes" \
    --description="Automatically switch cursor, icon, user, gtk theme according to the accent color activated by the system" \
    --gettext-domain="auto-switch-themes" \
    --settings-schema="org.gnome.shell.extensions.auto-switch-themes" \
    --interactive \
    --prefs
    # rm -f $HOME/.local/share/gnome-shell/extensions/auto-switch-themes@lcqh2635
    # 2、测试扩展
    # 在 GNOME 49 及更高版本上，您可能需要安装 mutter-devel
    sudo dnf install -y mutter-devel
    dbus-run-session gnome-shell --devkit --wayland
    # gnome-extensions uninstall auto-switch-themes@lcqh2635
    
    # 1、准备翻译
    # https://gjs.guide/extensions/development/translations.html
    mkdir -vp ~/.local/share/gnome-shell/extensions/auto-switch-themes@lcqh2635/{locale,utils,icons,ui,preferences}
    # 2、扫描可翻译的字符串
    # Gettext 使用 POT 文件（可移植对象模板）来存储所有可翻译字符串的列表。您可以通过使用 xgettext 扫描您的扩展源代码来生成 POT 文件：
    # 翻译者可以使用 .pot 文件，通过 Gtranslator 或 POEdit 等程序创建为其语言翻译的 .po 文件。
    cd ~/.local/share/gnome-shell/extensions/auto-switch-themes@lcqh2635
    xgettext --from-code=UTF-8 --output=po/auto-switch-themes@lcqh2635.pot *.js
    # 3、编译翻译
    gnome-extensions pack --podir=po auto-switch-themes@lcqh2635
    # 4、下一步
    # 在开发用户界面时，请记住您的扩展现在可能被用于从左到右或从右到左书写的语言。
    # 您可能还想考虑使用 Weblate https://weblate.org/zh-hans/ 或 Crowdin https://crowdin.com/ 等翻译服务注册您的项目。
    
    # 偏好设置
    # https://gjs.guide/extensions/development/preferences.html
    # 为您的扩展创建一个偏好设置窗口，允许用户配置扩展的外观和行为。它还可以包含文档、变更日志和其他信息。
    # 用户界面将使用GTK4和Adwaita创建，这些工具包含许多专门用于设置和配置的元素。你可以考虑查阅GNOME人类界面指南，或参考组件库以获取灵感。
    
    # 可访问性
    # https://gjs.guide/extensions/development/accessibility.html
    
    # 针对旧版 GNOME 版本
    # https://gjs.guide/extensions/development/targeting-older-gnome.html
    # "shell-version": [ "48", "49", "50" ]
    
    # TypeScript 和 LSP
    # 本页面将指导您使用 TypeScript 创建扩展，这将使自动补全功能在您的编辑器中正常工作。
    # 这里提供的设置与编辑器无关，并且将适用于任何支持语言服务器协议（LSP）或具有某些内部等效功能的编辑器。
    # https://gjs.guide/extensions/development/typescript.html
}

# 所有系统级别（对所有用户有效）的主题都存放在以下根目录中：
# nautilus admin:/usr/share/themes
# nautilus admin:/usr/share/icons
# sudo rm -rf /usr/share/icons/WhiteSur*
# ------------------------------------------------------------------------------
# 模块 6: 主题与美化 (WhiteSur)
# ------------------------------------------------------------------------------
install_theme_whitesur() {
    # https://github.com/topics/macos-tahoe
    # https://github.com/kayozxo/GNOME-macOS-Tahoe
    # https://github.com/taj-ny/kwin-effects-forceblur
    
    # 帮助新手和专家一起轻松自动化构建终极 macOS 虚拟机，由 KVM 驱动。现在支持 macOS Tahoe
    # https://github.com/Coopydood/ultimate-macOS-KVM
    
    
    # MacTahoe-icon-theme 内包含 MacTahoe cursors theme，执行命令时，两种主题会一并安装
    # https://www.opendesktop.org/p/2299216/
    # https://github.com/vinceliuice/MacTahoe-icon-theme
    # https://github.com/vinceliuice/MacTahoe-icon-theme/tree/main/cursors
    # git clone --depth=1 https://github.com/vinceliuice/MacTahoe-icon-theme.git
    # sudo ./install.sh -d /usr/share/icons -t all -b
    sudo ./install.sh -d /usr/share/icons -t default -b
    # sudo ./install.sh -r
    # nautilus admin:/usr/share/icons
    # sudo rm -rf /usr/share/icons/MacTahoe*
    
    # MacTahoe-gtk-theme 内包含 MacTahoe wallpapers，但需要手动额外安装
    # https://www.gnome-look.org/p/2299211
    # https://github.com/vinceliuice/MacTahoe-gtk-theme
    # git clone --depth=1 https://github.com/vinceliuice/MacTahoe-gtk-theme.git
    # 使用 ACL 访问控制列表
    sudo dnf install acl
    # 赋予当前用户对系统指定目录的读写权限：
    sudo setfacl -R -m u:$USER:rw /usr/share/themes
    # nautilus ~/.config/gtk-4.0
    # nautilus admin:/usr/share/themes
    # sudo rm -rf /usr/share/themes/MacTahoe*
    ./install.sh -o solid -t all -b -l
    ./install.sh -t all -l --shell -i fedora -h smaller --round
    sudo cp -r ~/.themes/MacTahoe* /usr/share/themes/
    rm -rf ~/.themes
    # ./tweaks.sh -f monterey
    # sudo ./tweaks.sh -g -i fedora -b default
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    ./tweaks.sh -F
    # MacTahoe-Dark-solid-blue
    gsettings set org.gnome.shell.extensions.user-theme name 'MacTahoe-Dark-solid-blue'
    gsettings set org.gnome.desktop.interface gtk-theme 'MacTahoe-Dark-solid-blue'
    gsettings set org.gnome.desktop.wm.preferences theme 'MacTahoe-Dark-solid-blue'
    # nautilus ~/.local/share/gnome-background-properties
    # mkdir -vp ~/.local/share/gnome-background-properties
    # ./wallpaper/install-gnome-backgrounds.sh
    
    # 弹出确认对话框：会弹出一个图形化的确认框，询问你是否真的要登出。
    # gnome-session-quit --logout


    # https://github.com/EliverLara/Space
    # https://www.gnome-look.org/p/2131750
    # gsettings set org.gnome.desktop.interface gtk-theme "Space"
    # gsettings set org.gnome.desktop.wm.preferences theme "Space"

    THEME_DIR="$HOME/下载/WhiteSur-themes"
    if [ ! -d "$THEME_DIR" ]; then
        log_info "正在下载并安装 WhiteSur 主题..."
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        mkdir -vp "$THEME_DIR"
        cd "$THEME_DIR"
        # 克隆主题仓库 (使用浅克隆加速)
        REPOS=(
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-cursors.git"
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-icon-theme.git"
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
        )
        for repo in "${REPOS[@]}"; do
            name=$(basename "$repo" .git)
            if [ ! -d "$name" ]; then
                git clone --depth=1 "$repo"
            fi
        done
        # git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
        # 安装光标
        cd WhiteSur-cursors && sudo ./install.sh && cd ..
        gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
        # 安装图标
        # cd WhiteSur-icon-theme && ./install.sh && cd ..
        # cd WhiteSur-icon-theme && sudo ./install.sh -d /usr/share/icons -t all && cd ..
        cd WhiteSur-icon-theme && sudo ./install.sh -d /usr/share/icons -t all && cd ..
        # -d --dest 指定主题目的地目录（默认：$HOME/.local/share/icons）
        # -t --theme 指定主题颜色变体 [默认/紫色/粉色/红色/橙色/黄色/绿色/灰色/all]（默认：蓝色 blue）
        # -b --bold 安装加粗面板图标版本
        # sudo ./install.sh -d /usr/share/icons -t all -b
        # sudo ./install.sh -r
        gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
        # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
        # grep '$opacity: ' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
        # sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
        sed -i 's/0\.96/1/g' WhiteSur-gtk-theme/src/sass/_colors.scss
        # 安装 GTK 主题
        cd WhiteSur-gtk-theme
        ./install.sh -l -o solid
        # nautilus ~/.config/gtk-4.0
        # 
        # Fix for libadwaita (not perfect)
        # https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/913
        # 白天：	ln -fs $HOME/.config/gtk-4.0/gtk-Light.css $HOME/.config/gtk-4.0/gtk.css
	# 晚上:		ln -fs $HOME/.config/gtk-4.0/gtk-Dark.css $HOME/.config/gtk-4.0/gtk.css
        # Do not run '-l --libadwaita' option with sudo!
        # ./install.sh -l -c dark        # Default is the dark theme for libadwaita
        # ./install.sh -l -c light       # install light theme for libadwaita
        # 将 /usr/share/themes 及其子文件的所有权都交给了你的用户账户
        # nautilus admin:/usr/share/themes
        ./install.sh -l -c dark -o solid && sudo ./install.sh -d /usr/share/themes -o solid -t all && cd ..
        # ./install.sh -l -c light && sudo ./install.sh -d /usr/share/themes -o solid -t all && cd ..
        
        gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
        gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
        gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
        # 简单处理 Firefox 进程，避免安装脚本报错
        if pgrep -x "firefox" > /dev/null; then
            log_warn "Firefox 正在运行，尝试关闭以应用主题..."
            pkill firefox
            sleep 2
        fi
        ./tweaks.sh -f flat
        ./tweaks.sh -F -o solid
        # 应用自定义背景
        sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/wallpaper-noon.jpg"
        rm -rf "$THEME_DIR"
        log_success "WhiteSur 主题安装完成。请在 GNOME Tweaks 中手动选择主题。"
    else
        log_warn "WhiteSur 主题已经安装，无需再次安装。"
    fi
    
    # 安装 Ubuntu 的声音主题
    sudo dnf install -y yaru-sound-theme
    gsettings set org.gnome.desktop.sound theme-name 'Yaru'
}

# 卸载主题
uninstall_theme() {
    cd ~/下载/WhiteSur-themes/WhiteSur-cursors && ./install.sh -r
    cd ~/下载/WhiteSur-themes/WhiteSur-icon-theme && ./install.sh -r
    cd ~/下载/WhiteSur-themes/WhiteSur-gtk-theme && ./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
}

# 重置系统字体配置
reset_font() {
    # dnf list *fonts*
    # Noto Fonts（思源黑体/宋体 的谷歌版本）
    # Noto Sans（无衬线体，类似思源黑体）：界面清晰，适合屏幕显示。
    # Noto Serif（衬线体，类似思源宋体）：适合长篇文档阅读。
    # JetBrains Mono JetBrains 公司专门为 IDE 设计的字体。字母宽度大，容易区分 1、l、I，默认支持连字符，非常耐看。
    # 系统界面（中文）	Noto Sans CJK SC	谷歌思源黑体，字库全，笔画均衡，与 Inter 风格协调
    # 文档阅读/写作	Noto Serif CJK SC	思源宋体，适合长时间阅读，衬线带来轻松的纸质感
    # 编程/终端		JetBrains Mono		字母区分度高，支持连字，视觉疲劳度低
    # fonts-noto-cjk 这个软件包直接提供了思源黑体和思源宋体在 Ubuntu 系统中的标准版本
    # Noto Sans CJK SC （思源黑体——简体中文）
    # Noto Serif CJK SC （思源宋体——简体中文）
    sudo dnf install -y \
    google-noto-sans-cjk-fonts \
    google-noto-serif-cjk-fonts \
    adobe-source-han-sans-cn-fonts \
    adobe-source-han-serif-cn-fonts \
    jetbrains-mono-fonts
    # 设置 GNOME 桌面的默认界面字体，影响范围：应用程序菜单、按钮、标签、对话框等 UI 元素的字体
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK SC Regular 11'
    # 设置文档类内容的默认字体，影响范围：文本编辑器、帮助文档、网页内容（某些应用中）等以“文档”形式展示的内容
    gsettings set org.gnome.desktop.interface document-font-name 'Noto Serif CJK SC Regular 11'
    # 设置等宽字体，影响范围：终端、代码编辑器
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Regular 11'
    # 设置窗口标题栏字体，影响范围：所有应用程序窗口顶部的标题文字
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans CJK SC Bold 11'
    # 微调：full（较好）或 slight
    gsettings set org.gnome.desktop.interface font-hinting 'slight'
    # 抗锯齿：rggb（LCD 显示器常用）或 grayscale
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
}

# 重置系统主题配置
reset_theme() {
    # 查看已安装包的依赖
    # rpm -qR adwaita-fonts-all
    # 查看未安装包（仓库中）的依赖
    # dnf repoquery --requires adwaita-fonts-all
    gsettings get org.gnome.desktop.interface font-name
    gsettings get org.gnome.desktop.interface document-font-name
    gsettings get org.gnome.desktop.interface monospace-font-name
    gsettings get org.gnome.desktop.wm.preferences titlebar-font
    gsettings get org.gnome.desktop.interface font-hinting
    gsettings get org.gnome.desktop.interface font-antialiasing

    gsettings reset org.gnome.desktop.interface font-name
    gsettings reset org.gnome.desktop.interface document-font-name
    gsettings reset org.gnome.desktop.interface monospace-font-name
    gsettings reset org.gnome.desktop.wm.preferences titlebar-font
    gsettings reset org.gnome.desktop.interface font-hinting
    gsettings reset org.gnome.desktop.interface font-antialiasing
    
    gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 12'
    gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 12'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 12'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Adwaita Sans Bold 12'
    
    gsettings reset org.gnome.desktop.interface cursor-theme
    gsettings reset org.gnome.desktop.interface icon-theme
    gsettings reset org.gnome.shell.extensions.user-theme name
    gsettings reset org.gnome.desktop.interface gtk-theme
    gsettings reset org.gnome.desktop.wm.preferences theme
    gsettings reset org.gnome.desktop.sound theme-name
}

set_theme_example() {
    # nautilus ~/.config/gtk-4.0
    # Fix for libadwaita (not perfect)
    # https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/913
    # 白天：	ln -fs $HOME/.config/gtk-4.0/gtk-Light.css $HOME/.config/gtk-4.0/gtk.css
    # 晚上:	ln -fs $HOME/.config/gtk-4.0/gtk-Dark.css $HOME/.config/gtk-4.0/gtk.css

    gsettings set org.gnome.desktop.interface color-scheme 'default'
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
    gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'
    gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'
    gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'
    ln -fs $HOME/.config/gtk-4.0/gtk-Light.css $HOME/.config/gtk-4.0/gtk.css

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
    gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
    ln -fs $HOME/.config/gtk-4.0/gtk-Dark.css $HOME/.config/gtk-4.0/gtk.css
}

# ------------------------------------------------------------------------------
# 模块 8: Git 配置
# ------------------------------------------------------------------------------
configure_git() {
    # 将上面生成的 SSH 密钥复制到剪切板，需要安装 wl-clipboard 工具
    # cat ~/.ssh/id_rsa.pub | wl-copy
    # 配置 Gitee 密钥	https://gitee.com/profile/sshkeys
    # 配置 Github 密钥	https://github.com/settings/keys
    # cd ~/文档 && git clone git@github.com:lcqh2635/linux-setup.git
    # cd ~/下载 && git clone https://gitee.com/lcqh2635/init-fedora.git
    # cd ~/下载 && git clone https://gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
    if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
        log_info "配置 Git..."
        # 这里使用占位符，实际使用时建议用户手动修改或通过参数传入
        read -p "请输入您的 Git 用户名 (默认 lcqh2635): " GIT_NAME
        GIT_NAME=${GIT_NAME:-lcqh2635}

        read -p "请输入您的 Git 邮箱 (默认 lcqh2635@gmail.com): " GIT_EMAIL
        GIT_EMAIL=${GIT_EMAIL:-lcqh2635@gmail.com}

        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"

        log_info "生成 SSH 密钥..."
        ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_rsa" -N ""
        log_info "公钥内容已复制到剪贴板 (需 wl-clipboard)，请添加到 GitHub/Gitee。"
        cat "$HOME/.ssh/id_rsa.pub" | wl-copy
        cat "$HOME/.ssh/id_rsa.pub"
    else
        log_warn "SSH 密钥已存在，跳过生成。"
    fi
}


# ------------------------------------------------------------------------------
# 模块 7: JetBrains 工具箱 (官方安装)
# ------------------------------------------------------------------------------
install_jetbrains_toolbox() {
    cd "$HOME/下载"
    
# 启用第三方优质库	https://copr.fedorainfracloud.org
# 基于以下 Github 仓库创建一个 Fedora Copr 用户仓库	git clone --depth=1 git@github.com:lcqh2635/fedora.git
# https://copr.fedorainfracloud.org/coprs/lcqh2635/gnome-shell-extensions/
# sudo dnf copr enable -y lcqh2635/gnome-shell-extensions
# https://copr.fedorainfracloud.org/coprs/lcqh2635/fedora-software-extras/
# sudo dnf copr enable -y lcqh2635/fedora-software-extras
# https://copr.fedorainfracloud.org/coprs/lcqh2635/jetbrains/
# sudo dnf copr enable -y lcqh2635/jetbrains

# git clone --depth=1 https://github.com/kris3713/YACR.git
# git clone --depth=1 https://github.com/OskarKarpinski/rpm.git
# git clone --depth=1 https://github.com/xariann-pkg/fedora-tools.git
# https://copr.fedorainfracloud.org/coprs/holeprof/fedora-extended/packages/
# https://copr.fedorainfracloud.org/coprs/tigro/fedora44/packages/


# 包含 jetbrains-toolbox 仓库
# dnf repolist
# https://copr.fedorainfracloud.org/coprs/zliced13/YACR/
# cat /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:zliced13:YACR.repo
sudo dnf copr enable -y zliced13/YACR
# 禁用仓库 ( 对应 enabled=0 )
sudo dnf config-manager setopt copr:copr.fedorainfracloud.org:zliced13:YACR.enabled=0
# 删除仓库
sudo rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:zliced13:YACR.repo
# 使用 sudo dnf config-manager addrepo 改写，上面写法的等效替代
# 综合参考示例，可参考： 
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/jetbrains-toolbox.repo
# 如果你希望 baseurl 中包含变量（如 $releasever、$basearch），关键在于引号的使用。
# 你需要使用单引号（'）将 URL 包裹起来。如果使用双引号，Shell 会在命令传递给 DNF 之前尝试解析并替换这些变量（通常会导致变量为空或报错）
sudo dnf config-manager addrepo \
  --id=jetbrains-toolbox \
  --save-filename=jetbrains-toolbox.repo \
  --set=name='Jetbrains Toolbox $releasever - $basearch' \
  --set=baseurl='https://download.copr.fedorainfracloud.org/results/zliced13/YACR/fedora-$releasever-$basearch/' \
  --set=enabled=1 \
  --set=countme=1 \
  --set=enabled_metadata=1 \
  --set=metadata_expire=7d \
  --set=type=rpm-md \
  --set=gpgcheck=1 \
  --set=gpgkey="https://download.copr.fedorainfracloud.org/results/zliced13/YACR/pubkey.gpg" \
  --set=repo_gpgcheck=0 \
  --set=skip_if_unavailable=True \
  --overwrite
# 更新系统软件包并安装对应软件
sudo dnf update
sudo dnf install -y jetbrains-toolbox postman
# sudo dnf reinstall -y jetbrains-toolbox postman
# 禁用仓库 ( 对应 enabled=0 )
sudo dnf config-manager setopt jetbrains-toolbox.enabled=0
# 删除仓库
sudo rm -f /etc/yum.repos.d/jetbrains-toolbox.repo


# https://copr.fedorainfracloud.org/coprs/holeprof/fedora-extended/
sudo dnf copr enable -y holeprof/fedora-extended
# 更新系统软件包并安装对应软件
sudo dnf update
sudo dnf install -y jetbrains-toolbox extension-manager fedora-update gdm-settings obsidian zen-browser
# sudo dnf install -y dnf5-autosnapper protonplus themechanger
# sudo dnf reinstall -y jetbrains-toolbox postman
# 禁用仓库 ( 对应 enabled=0 )
sudo dnf config-manager setopt jetbrains-toolbox.enabled=0
# 删除仓库
sudo rm -f /etc/yum.repos.d/jetbrains-toolbox.repo

# git clone --depth=1 git@github.com:lcqh2635/jetbrains.git
# git clone --depth=1 https://github.com/M3DZIK/rpm.git
# https://copr.fedorainfracloud.org/coprs/medzik/jetbrains/
# sudo dnf copr enable medzik/jetbrains
# dnf list goland
# sudo dnf install -y intellij-idea-ultimate
# sudo dnf install -y goland webstorm rustrover datagrip android-studio pycharm-professional
    
    # 方法：尝试列出匹配的文件，如果有任何输出，说明存在
    if compgen -G "$HOME/.apps/jetbrains-toolbox-*" > /dev/null; then
        echo "✅ 已找到 JetBrains Toolbox 目录，跳过安装。"
    else
        echo "正在安装 JetBrains Toolbox..."
	# 获取最新正式版链接 (排除 arm64)
	DOWNLOAD_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | \
		grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | \
		grep -v 'arm64' | head -1)
	if [ -z "$DOWNLOAD_URL" ]; then
	    log_error "无法获取 JetBrains Toolbox 下载链接。"
	    return 1
	fi
        wget -O jetbrains-toolbox.tar.gz "$DOWNLOAD_URL"
        mkdir -vp "$HOME/.apps"
        tar -xzf jetbrains-toolbox.tar.gz -C "$HOME/.apps"
	# 找到解压后的目录并运行
	TOOLBOX_DIR=$(find "$HOME/.apps" -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -1)
	if [ -n "$TOOLBOX_DIR" ]; then
	    chmod +x "$TOOLBOX_DIR/bin/jetbrains-toolbox"
	    log_info "启动 JetBrains Toolbox..."
	    # 在后台运行
	    "$TOOLBOX_DIR/bin/jetbrains-toolbox" &
	    log_success "JetBrains Toolbox 已启动。请按照界面提示完成后续配置。"
	    log_warn "注意：本脚本不包含自动激活破解补丁，请使用正版授权或学生认证。"
	else
	    log_error "解压 JetBrains Toolbox 失败。"
	fi
        rm -rf jetbrains-toolbox*
        
        # https://3.jetbra.in/
        # https://github.com/jonssonyan/3.jetbra.in
        # https://account.jetbrains.com/licenses
        if compgen -G "$HOME/下载/jetbra-*" > /dev/null; then
            echo "✅ 已找到 jetbra 目录，跳过下载和安装。"
        else
            log_info "正在安装 jetbra 工具x..."
            wget https://3.jetbra.in/files/jetbra-5a50fc03d68a014f893b7fc3aa465380d59f9095.zip
            unzip jetbra-*.zip && mv jetbra ~/.jetbra
            # nautilus ~/.jetbra
	    
	    # https://www.jetbrains.com/zh-cn/help/idea/tuning-the-ide.html
	    # https://www.jetbrains.com/zh-cn/help/idea/2026.1/getting-started.html?keymap=GNOME
	    # 生效机制：IntelliJ IDEA 启动时，会优先读取用户配置目录（~/.config/JetBrains/IntelliJIdea2026.1/）下的 idea64.vmoptions 文件。
	    # 如果这个文件存在，IDEA 就会忽略安装目录 （~/.local/share/JetBrains/Toolbox/apps/intellij-idea/）下的那个文件。
	    
	    # 全局默认配置，优先级低。仅当用户目录没有该文件时生效。
	    # 持久性：不稳定。使用 Toolbox 更新或重装 IDEA 时，该文件可能会被重置或覆盖。
	    # 作用：定义 IDEA 出厂时的默认内存、GC 策略等参数。作为用户自定义配置的参考
	    # ~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea64.vmoptions
	    # nautilus ~/.local/share/JetBrains/Toolbox/apps
	    
	    # 用户自定义配置，优先级高。启动时会覆盖安装目录的配置。
	    # 持久性：持久。独立于软件安装，更新 IDEA 版本后配置通常会保留或迁移。
	    # 作用：存放你修改后的个性化参数。
	    # ~/.config/JetBrains/IntelliJIdea2026.1/idea64.vmoptions
	    # nautilus ~/.local/share/JetBrains/Toolbox/apps
	    
	    # 自动配置  jetbrains 代码编辑器 vmoptions
            # --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
	    # --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
	    # -javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
            rm -rf jetbra*
        fi
        log_warn "JetBrains Toolbox 已经安装"
    fi
}

# VPN 相关软件和订阅来源
# https://gitclone.com/
# https://gh-proxy.com/
# https://github.akams.cn/
# https://xiake.pro/
# https://ghproxylist.com/
# https://www.freeclashnode.com/
install_vpn() {
    # 进入到下载目录
    cd ~/下载
    # Github 加速工具
    # https://github.com/docmirror/dev-sidecar
    # https://github.com/docmirror/dev-sidecar/releases
    
    # https://v2rayn.co/
    # https://github.com/2dust/v2rayN/releases
    # 使用教程	https://v2rayn.co/v2rayn-tutorial/
    # 1、点击顶部菜单栏的 “订阅分组”，选择 “订阅分组设置”，在弹出的窗口中点击 "添加"，
    # 2、添加订阅节点完成后回到主界面，点击 “订阅分组” -> “更新全部订阅 (不通过代理)” 操作完成后，你应该能看到列表中出现了一排节点
    # 3、开启代理与模式选择。这是最关键的一步，决定了电脑是否已经处于代理加速状态
    	# 3.1、选择节点。 在节点列表中，点击上方的 “网络测速图标” 进行 “一键多线程测试延迟和速度”，选择网速最好的节点并将其设为活动，当节点的别名变色或显示“活动”状态时，表示已选中
    	# 3.2、设置系统代理。在软件界面的最底部图标栏，找到以下三项关键设置：
    		# 系统代理：将其设置为 自动配置系统代理。此时底部图标会变为红色
    		# 路由：将其设置为 绕过大陆。这可以确保访问百度、淘宝等国内网站时不走代理，访问 YouTube、Google 时才加速
    # 4、测试网络。打开浏览器，尝试访问 Google。如果能正常打开，恭喜，配置已成功
    # 5、v2rayN 高级设置说明：
    # TUN 模式，在软件底部可以找到 TUN 模式开关
    	# 作用：接管整机流量。对于一些不遵循系统代理的浏览器插件、游戏或特定软件非常有用
    	# 建议：普通网页浏览不需要开启，仅在某些软件无法正常代理时开启
    # 核心选择：v2rayN 支持切换 Xray-core、sing-box 等核心。目前大部分订阅链接都支持 Xray，保持默认即可
    if rpm -q "v2rayN" > /dev/null 2>&1; then
        echo "✅ v2rayN 已安装"
        # 这里可以执行后续操作
    else
        echo "❌ v2rayN 未安装，开始下载并安装 v2rayN"
        wget "$(curl -s https://api.github.com/repos/2dust/v2rayN/releases/latest | \
          grep -o 'https://github.com/2dust/v2rayN/releases/download/[^"]*v2rayN-linux-rhel-64\.rpm' | \
          head -n 1 | \
          sed "s|https://github.com|${GITHUB_PROXY_URL}https://github.com|")"
        sudo dnf install -y ./v2rayN-linux-rhel-64.rpm
    fi

    # https://clashverge.net/clash-verge/
    # https://github.com/clash-verge-rev/clash-verge-rev
    if rpm -q "clash-verge" > /dev/null 2>&1; then
        echo "✅ Clash.Verge 已安装"
        # 这里可以执行后续操作
    else
        echo "❌ Clash.Verge 未安装，开始下载并安装 Clash.Verge"
        wget "$(curl -s https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest | \
            grep -o 'https://github.com/clash-verge-rev/clash-verge-rev/releases/download/[^"]*x86_64\.rpm' | \
            head -n 1 | \
            sed "s|https://github.com|${GITHUB_PROXY_URL}https://github.com|")"
        sudo dnf install -y ./Clash.Verge-*.x86_64.rpm
    fi
    
    # 🩵 一个免费的、开源的应用商店，用于 GitHub 发布 — 一键浏览、发现和安装应用。
    # 由 Kotlin 和 Compose Multiplatform 为 Android 和桌面（Linux、MacOS、Windows）提供支持。
    # https://github.com/OpenHub-Store/GitHub-Store
    wget "$(curl -s https://api.github.com/repos/OpenHub-Store/GitHub-Store/releases/latest | \
        grep -o 'https://github.com/OpenHub-Store/GitHub-Store/releases/download/[^"]*x86_64\.rpm' | \
        head -n 2 | \
        sed "s|https://github.com|https://edgeone.gh-proxy.org/https://github.com|")"
    sudo dnf install -y ./GitHub-Store-*.x86_64.rpm
    
    # https://github.com/hiddify/hiddify-app/blob/main/README_cn.md
    # 一款基于 Sing-box 通用代理工具的跨平台代理客户端。Hiddify 提供了较全面的代理功能，例如自动选择节点、TUN 模式、使用远程配置文件等。Hiddify 无广告，并且代码开源。
    # 它为大家自由访问互联网提供了一个支持多种协议的、安全且私密的工具。多种订阅链接和配置文件格式支持： Sing-box、V2ray、Clash、Clash meta
    # Hiddify 使用教程 https://hiddify.la/tutorial/
    # 免费通用机场节点仓库  https://github.com/mksshare/mksshare.github.io
    	# https://pPiPDy.mcsslk.xyz/fa998be69a450c433133472d2ddd7a68
    	# https://woDF6n.tosslk.xyz/2c58cc7fb6edb08f1b88e0ce07f03f78
    # 对于 AppImage 格式应用的安装，先打开 AppImage 安装管理器 Gear Lever 这个软件 flatpak run it.mijorus.gearlever 配置 AppImage 安装目录为 ~/.apps 然后点击 + 添加下面的 AppImage 应用
    if [ -f "$HOME/.apps/appimages/Hiddify-Linux-x64-AppImage.AppImage" ]; then
        echo "✅ Hiddify 已安装"
        # 这里可以执行后续操作
    else
        echo "❌ Hiddify 未安装，开始下载并安装 Hiddify"
        mkdir -vp ~/.apps/appimages && cd ~/.apps/appimages
        wget "$(curl -s https://api.github.com/repos/hiddify/hiddify-app/releases/latest | \
            grep -o 'https://github.com/hiddify/hiddify-app/releases/download/[^"]*Linux-x64.*\.AppImage' | \
            head -n 1 | \
            sed "s|https://github.com|${GITHUB_PROXY_URL}https://github.com|")"
        # 1. 赋予执行权限
        chmod +x Hiddify-Linux-x64-*.AppImage
        # 2. 运行程序
        ./Hiddify-Linux-x64-*.AppImage
        cd ~/下载
    fi
    
    yaru-icon-theme yaru-gtk4-theme
    sweet-gtk-theme
    numix-icon-theme numix-gtk-theme
    oxygen-icon-theme
    breeze-cursor-theme breeze-icon-theme
    # https://github.com/lassekongo83/adw-gtk3
    # 将 GNOME 最新的默认视觉风格（Libadwaita）移植到旧的 GTK 3 应用程序上
    # 让那些基于 GTK 3 的老程序也能拥有和新一代 GNOME 应用（如设置、文件、终端等）几乎一模一样的外观。
    sudo dnf install -y adw-gtk3-theme
    # flatpak list --all
    # 搜索远程仓库的应用/运行时
    # flatpak search org.gtk.Gtk3theme
    flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    # mask 屏蔽更新和自动安装
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3-dark
    # https://wiki.archlinux.org.cn/title/Uniform_look_for_Qt_and_GTK_applications
    # mkdir -vp ~/.config/Kvantum
    # sudo dnf install -y kvantum

    log_info "正在安装 Flatpak 常用应用程序..."
    # 不推荐在 flatpak install 命令前加 sudo 这样不需要 root 权限，不会影响系统其他用户，卸载或管理时也不需要密码，更安全。
    # 对于个人日常使用，请去掉 sudo。这样不需要每次输入密码、更方便、更安全，也符合 Flatpak 的设计初衷
    
    # GNOME 扩展负责更新扩展、配置扩展偏好以及移除或禁用不需要的扩展
    flatpak install -y flathub org.gnome.Extensions
    # 浏览并安装GNOME Shell 扩展以定制你的桌面
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    # 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
    flatpak install -y flathub io.github.kolunmi.Bazaar
    # Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
    flatpak install -y flathub com.github.tchx84.Flatseal
    # Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
    flatpak install -y flathub io.github.flattool.Warehouse
    # 卸载Flatpak时，可能会在电脑上留下一些文件。Flatsweep 帮助您轻松清除未安装 Flatpak 残留在系统上的残留物
    flatpak install -y flathub io.github.giantpinkrobots.flatsweep
    # 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
    flatpak install -y flathub io.github.realmazharhussain.GdmSettings
    # 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了
    flatpak install -y flathub io.gitlab.adhami3310.Impression
    # 一个易用的BitTorrent客户端。片段可以通过BitTorrent点对点文件共享协议传输文件，例如视频、音乐或Linux发行版的安装映像
    flatpak install -y flathub de.haeckerfelix.Fragments
    # 用干净、无干扰的标记删除编辑器专注于你的写作
    flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
    # 忘记忘记事情
    flatpak install -y flathub io.github.alainm23.planify
    # 一款极简的Markdown阅读与写作应用
    flatpak install -y flathub io.typora.Typora
    # 你可以从拥有简洁友好的用户界面的在线来源获取字体。Sitra为安装、卸载和预览字体提供了无缝体验
    flatpak install -y flathub io.github.sitraorg.sitra
    # Refine 帮助发现 GNOME 中的高级和实验性功能
    flatpak install -y flathub page.tesk.Refine
    # Rewaita通过用流行的配色方案为您的Adwaita应用增添新意
    flatpak install -y flathub io.github.swordpuffin.rewaita
    # 一款用 GTK4 编写的轻量级音乐播放器，专注于大型音乐收藏
    flatpak install -y flathub com.github.neithern.g4music
    # 开启桌面歌词功能需要的依赖 https://github.com/osdlyrics/osdlyrics
    # netease-cloud-music-gtk 是使用 Rust + GTK 开发的网易云音乐客户端，专为 Linux 系统打造
    flatpak install -y flathub com.github.gmg137.netease-cloud-music-gtk
    # 一个轻松管理 AppImages 的工具！齿轮杆可以帮你整理和管理 AppImage 文件，生成桌面条目和应用元数据，原地更新应用，或将多个版本并排保存
    flatpak install -y flathub it.mijorus.gearlever
    # Microsoft Edge 网络浏览器
    flatpak install -y flathub com.microsoft.Edge
    # Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
    flatpak install -y flathub com.google.Chrome
    # Playhouse 让原型制作、教学、设计、学习和构建网页内容变得简单
    flatpak install -y flathub re.sonny.Playhouse
    # Workbench 是用来学习和用 GNOME 技术做原型设计的，无论是第一次动手还是构建和测试 GTK 用户界面
    flatpak install -y flathub re.sonny.Workbench
    flatpak install -y flathub com.github.marhkb.Pods
    # flatpak install -y flathub dev.skynomads.Seabird
    # Thunderbird 是一款免费且开源的电子邮件、新闻源、聊天和日历客户端
    flatpak install -y flathub org.mozilla.Thunderbird

    # 设置 Dock 栏应用图标
    gsettings set org.gnome.shell favorite-apps "['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Ptyxis.desktop', 'org.gnome.Settings.desktop', 'org.gnome.SystemMonitor.desktop', 'com.microsoft.Edge.desktop', 'org.gnome.tweaks.desktop']"


    log_success "Flatpak 应用安装完成。"
}



# ------------------------------------------------------------------------------
# 模块 9: 安装并配置  Oh My Zsh
# ------------------------------------------------------------------------------
configure_ohmyzsh() {
    if rpm -q "zsh" > /dev/null 2>&1; then
        echo "✅ zsh 已安装"
        # 这里可以执行后续操作
    else
        echo "❌ zsh 未安装，开始下载并安装 zsh"
        # 安装 Zsh
        # https://linuxcapable.com/how-to-install-zsh-on-fedora-linux/
        sudo dnf install -y zsh zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting 
        echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
        echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
        source ~/.zshrc
        # 将 Zsh 设为默认 Shell，使用 chsh 将登录壳改为 Zsh：
        # 提示时输入密码。该更改将在你登出再重新登录，或在当前会话中手动启动 Zsh 后生效：
        chsh -s $(which zsh)
        # chsh -s $(which bash)
        # 登出再重新登录后，确认 Zsh 是你的默认 shell：
        echo $SHELL
        # 安装 Oh My Zsh
        # 前提条件，应该提前安装 zsh、curl、git，如果没有预装（运行 zsh --version 确认）
        # https://github.com/ohmyzsh/ohmyzsh
        # 脚本会将你现有的 ~/.zshrc 备份到 ~/.zshrc.pre-oh-my-zsh，并创建一个新的配置文件。如果提示更改默认壳，如果之前跳过了，请输入 y
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

set_grub2_theme() {
    # https://github.com/VandalByte/grub-tweaks
    # 安装 GRUB2 主题，并配置多系统时的扫描
    # https://www.gnome-look.org/browse?cat=109&ord=rating
    sudo cp /etc/default/grub /etc/default/grub.bak
    sudo cp -r /boot/grub/ /boot/grub.bak # 防止配置失效导致系统无法启动‌
    sudo dnf install -y grub2-breeze-theme
    # https://github.com/VandalByte/darkmatter-grub2-theme/
    git clone --depth 1 https://gh-proxy.org/https://github.com/VandalByte/darkmatter-grub2-theme.git
    cd darkmatter-grub2-theme
    # 安装主体
    sudo python3 darkmatter-theme.py -i
    # 卸载主题
    # sudo python3 darkmatter-theme.py -u
    # 设置GRUB显示分辨率
    # 首先找到你的屏幕分辨率
    sudo dnf install -y xdpyinfo lsb_release
    xdpyinfo | awk '/dimensions/{print $2}'
    # 打开文件 /etc/default/grub，编辑行 GRUB_GFXMODE=[宽度]x[高度]x32以匹配你的分辨率
    # 备份到同目录（添加 .bak 后缀）
    sudo cp /etc/default/grub{,.bak}
    # 检查 .bak 文件是否存在
    # ls /etc/default && cat /etc/default/grub
    # 从同目录 .bak 文件恢复
    # sudo cp /etc/default/grub{.bak,}
    # tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | sudo tee /etc/default/grub
# ==============================================================================
# Fedora GRUB2 配置文件示例 (/etc/default/grub)
# ==============================================================================
# 说明：
# 1. 本文件用于控制 GRUB 引导加载程序的行为。
# 2. 修改此文件后，必须运行 'sudo grub2-mkconfig' 命令重新生成配置才能生效。
# 3. 以 '#' 开头的行为注释，不会被执行。
# 4. GRUB2 文档	https://fedoraproject.org/wiki/GRUB_2/zh-cn
# ==============================================================================

# ------------------------------------------------------------------------------
# [基础设置]
# ------------------------------------------------------------------------------

# 设置 GRUB 菜单在自动启动前的等待时间（单位：秒）。
# - 设置为 0：立即启动默认项，不显示菜单（不推荐双系统用户）。
# - 设置为 -1：无限等待，直到用户手动选择（适合需要频繁切换系统的用户）。
# - 设置为 5~10：推荐值，给用户足够的时间选择操作系统。
GRUB_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT=0

# 动态获取当前安装的 Linux 发行版名称，并将其显示在 GRUB 启动菜单的条目中。
# 简单来说，它决定了你在开机启动菜单里看到的名字是 Fedora、Fedora Linux 还是其他变体，而不是写死在配置文件里的硬编码字符串。
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"

# 设置默认的启动项。
# - 0：启动菜单中的第一项（通常是 Fedora）。
# - 1, 2, ...：启动菜单中的第二、第三项（如果 Windows 被识别为第二项，这里填 1）。
# - "saved"：记住上次用户手动选择的系统，下次优先启动该系统（双系统推荐）。
#   *注意：若使用 "saved"，通常建议同时启用下方的 GRUB_SAVEDEFAULT=true*
GRUB_DEFAULT=saved

# 启用“保存上次选择”功能。
# - true：当 GRUB_DEFAULT 设置为 "saved" 时，用户手动选择的启动项会被记录，
#         下次重启时自动作为默认项。这对双系统用户非常友好。
# - false：每次重启都强制回到 GRUB_DEFAULT 指定的固定项。
GRUB_SAVEDEFAULT=true

# 强制 GRUB 将所有启动项（包括不同内核版本、恢复模式等）直接平铺显示在主菜单的第一页，而不是折叠进一个“高级选项”子菜单中。
# 如果你是普通桌面用户，且只关心“启动最新的 Fedora”和“启动 Windows”，保持默认（即不使用该选项，或设为 false） 更好，界面更清爽。
# 如果你经常需要手动选择旧内核，或者觉得进入子菜单很麻烦，那么设置 GRUB_DISABLE_SUBMENU=true 是一个非常实用的优化。
GRUB_DISABLE_SUBMENU=false

# 设置菜单样式。
# - "console"：纯文本模式（兼容性最好，默认）。
# console：代表“控制台”。这意味着你在开机选择系统时，看到的将是一个黑底白字（或白底黑字）的简单列表，没有背景图片、没有进度条动画、也没有漂亮的字体渲染。
# - "gfxterm"：图形化模式（需要加载主题和字体，更美观）。
# gfxterm (Graphics Terminal)：这是现代发行版（如 Fedora, Ubuntu）的默认推荐值。它加载显卡驱动，支持高分辨率、背景图片、主题美化以及图形化的启动进度条。
# 如果你的系统安装了 grub2-theme 包，通常保持默认或设为 gfxterm 即可。
GRUB_TERMINAL_OUTPUT="gfxterm"

# 是否禁用恢复模式菜单项。配置文件默认为："true"
# - false：显示恢复模式（推荐，方便系统出错时修复）。
# - true：隐藏恢复模式。
GRUB_DISABLE_RECOVERY="false"

# 启用“引导加载器规范配置”（Boot Loader Specification, BLS）支持
# 简单来说，它改变了 GRUB 管理启动项的方式：从“把所有启动项写在一个大文件里”变成了“每个内核版本对应一个独立的小配置文件”
GRUB_ENABLE_BLSCFG=true

# ------------------------------------------------------------------------------
# [双系统关键配置] (Fedora + Windows)
# ------------------------------------------------------------------------------

# 【重要】启用外部操作系统探测器 (os-prober)。
# - 背景：出于安全考虑，较新版本的 GRUB2 默认禁用了扫描其他硬盘分区的功能。
# - 作用：设置为 'false' 意味着“不要禁用 os-prober”，即允许 GRUB 扫描并添加 Windows 
#        或其他 Linux 发行版的启动项到菜单中。
# - 如果你发现重启后没有 Windows 选项，请确保这一行存在且值为 false。
GRUB_DISABLE_OS_PROBER=false

# ------------------------------------------------------------------------------
# [内核命令行参数] (传递给 Linux 内核的参数)
# ------------------------------------------------------------------------------

# 默认的内核启动参数。
# - rhgb：Red Hat Graphical Boot，启用图形化启动进度条（隐藏详细日志）。
# - quiet：安静模式，减少启动过程中打印到屏幕的详细日志信息。
# 如果需要排查启动故障，可以临时删除这两个参数以查看详细信息。
GRUB_CMDLINE_LINUX="rhgb quiet"

# 【高级】额外内核参数（可选）。
# - 这里的参数会追加到上面的 GRUB_CMDLINE_LINUX 之后。
# - 示例：nomodeset (解决显卡驱动导致的黑屏问题)
# - 示例：intel_iommu=on (开启虚拟化直通支持)
# - 示例：mem_sleep_default=deep (优化睡眠耗电问题，部分笔记本需要)
# 普通用户通常不需要修改此项，留空即可。
GRUB_CMDLINE_LINUX_DEFAULT=""

# ------------------------------------------------------------------------------
# [外观与主题] (可选)
# ------------------------------------------------------------------------------
# darkmatter-grub2-theme 官方仓库 https://github.com/VandalByte/darkmatter-grub2-theme/

# 设置 GRUB 菜单的分辨率。
# - 格式：宽x高 (例如 1920x1080、3840x2400 可使用 xdpyinfo | awk '/dimensions/{print $2}' 命令查看)。
# - auto：让 GRUB 自动检测最佳分辨率（推荐）。
# - 如果图形界面显示异常，可以尝试强制指定一个较低的分辨率，如 3840x2400。
GRUB_GFXMODE=auto

# 设置控制台分辨率（通常与 GFXMODE 保持一致）。
GRUB_GFXPAYLOAD_LINUX=keep

# 指定 GRUB 主题路径。
# - Fedora 默认主题通常位于 /usr/share/grub/themes/ 下。
# - 如果想自定义主题，需先安装主题包，然后在此处填写绝对路径。
# - 注释掉此行将使用默认样式。
# sudo ls /boot/grub2/themes
# GRUB_THEME="/boot/grub2/themes/dark-matter/theme.txt
EOF

    # sudo ls /boot/grub2 && sudo cat /boot/grub2/grub.cfg
    # 重新生成 GRUB 配置文件：保存并退出编辑器后，运行以下命令让更改生效并扫描 Windows：
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
}

# ------------------------------------------------------------------------------
# 主执行流程
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Fedora 初始化配置脚本 v2.0${NC}"
    echo -e "${BLUE}  作者：龙茶清欢 (优化版)${NC}"
    echo -e "${BLUE}========================================${NC}"

    if ! confirm_action "即将开始系统配置，过程中可能需要输入 sudo 密码。是否继续？"; then
        exit 0
    fi
    
    # 1. 基础 GNOME 设置
    configure_basics_gsettings
    # 2. 软件源与 DNF
    configure_repos_and_dnf
    check_repo
    # 3. 系统更新
    # system_update_and_cleanup
    # 4. 开发工具
    install_dev_tools
    configure_languages
    configure_git
    # 5. Flatpak 应用
    configure_flatpak_and_install_app
    # 7. JetBrains Toolbox
    if confirm_action "是否安装 JetBrains Toolbox？"; then
        install_jetbrains_toolbox
    else
        log_warn "跳过 JetBrains Toolbox 安装。"
    fi
    # 6. 安装 Gnome Shell 扩展
    install_gnome_extensions
    # 7. 主题美化 (可选)
    if confirm_action "是否安装 WhiteSur 主题并进行美化？"; then
        install_theme_whitesur
    else
        log_warn "跳过主题安装。"
    fi
    # 8. 最终清理
    log_info "执行最终清理..."
    sudo dnf autoremove -y
    sudo dnf clean all

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  配置全部完成！${NC}"
    echo -e "${GREEN}  建议重启系统以应用所有更改。${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    read -p "是否立即退出当前用户登录？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 想要彻底退出当前用户的所有程序并返回到登录屏幕（GDM）
        # 立即登出（不确认）：这会关闭所有打开的应用程序并返回到登录界面
        # gnome-session-quit --logout --no-prompt
        # 弹出确认对话框：会弹出一个图形化的确认框，询问你是否真的要登出。
        gnome-session-quit --logout
    fi
}

# 执行主函数
main "$@"
