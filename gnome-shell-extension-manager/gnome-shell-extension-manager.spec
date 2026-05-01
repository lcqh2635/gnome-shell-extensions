# ==============================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/lcqh2635/gnome-shell-extensions
# 参考文件 https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 官方网站 https://mattjakeman.com/apps/extension-manager
# 源代码仓库 https://github.com/mjakeman/extension-manager
# git clone --depth=1 https://github.com/mjakeman/extension-manager.git
# ==============================================================================

# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid rounded-window-corners@fxgn

# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与软件包名或项目名一致。
Name:           gnome-shell-extension-manager
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        0.6.5
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        1%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        A utility for browsing and installing GNOME Shell Extensions.
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:         GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/mjakeman/extension-manager
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
# https://github.com/mjakeman/extension-manager/archive/refs/tags/v0.6.5.zip
Source0:        %{url}/archive/refs/tags/v%{version}.zip

# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
# gnome-shell-devel: 提供 GNOME Shell 的开发宏和头文件。
# 虽然不是所有扩展都严格需要，但加上它可以确保环境一致性。
BuildRequires:    git
BuildRequires:    meson gcc blueprint-compiler desktop-file-utils libappstream-glib
BuildRequires:    pkgconfig(gtk4) pkgconfig(libadwaita-1) pkgconfig(libsoup-3.0) pkgconfig(json-glib-1.0)
# --- 运行依赖 (Requires) 用户安装此包时必须存在的软件 ---
# glib2: 运行时库，用于处理 GSettings 配置。
Requires:       gtk4 libadwaita
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch
# 强制该软件包只能在 64 位 Intel/AMD 架构的机器上安装和构建
ExclusiveArch:  x86_64

%description
A native tool for browsing, installing, and managing GNOME Shell Extensions.

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install
%find_lang %{name}

%check
appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/*.xml
desktop-file-validate %{buildroot}%{_datadir}/applications/*.desktop

%files -f %{name}.lang
%license COPYING
%{_bindir}/extension-manager
%{_metainfodir}/*.xml
%{_datadir}/applications/com.mattjakeman.ExtensionManager.desktop
%{_datadir}/glib-2.0/schemas/com.mattjakeman.ExtensionManager.gschema.xml
%{_datadir}/icons/hicolor/scalable/apps/com.mattjakeman.ExtensionManager.svg
%{_datadir}/icons/hicolor/symbolic/apps/com.mattjakeman.ExtensionManager-symbolic.svg

%changelog
* Wed Feb 25 2026 vani-tty1 <giovannirafanan609@gmail.com> - 0.6.5-5
- rebuild without libbacktrace
