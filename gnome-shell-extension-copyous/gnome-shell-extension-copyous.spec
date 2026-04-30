# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/gierth/tools-misc/
# 参考文件 https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/boerdereinar/copyous
# git clone --depth=1 https://github.com/boerdereinar/copyous.git


# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid copyous@boerdereinar.dev


# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-copyous
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        2.0.0
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        3%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        Modern Clipboard Manager for GNOME
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/boerdereinar/copyous
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
Source0:        %{url}/releases/download/v%{version}/%{uuid}.zip
# 方式2：使用本地克隆目录打包（用于测试）
# Source0: %{name}-%{version}.tar.gz


# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
BuildRequires:  glib2
# gnome-shell-devel: 提供 GNOME Shell 的开发宏和头文件。
# 虽然不是所有扩展都严格需要，但加上它可以确保环境一致性。
# BuildRequires:  gnome-shell-devel
# --- 运行依赖 (Requires) 用户安装此包时必须存在的软件 ---
# gnome-shell: 扩展运行的宿主环境。
Requires:       gnome-shell >= 48
# glib2: 运行时库，用于处理 GSettings 配置。
Requires:       glib2
# --- 推荐依赖 (Recommends) 非强制，但强烈建议安装以获得完整功能 ---
# libgda-sqlite: Copyous 使用 SQLite 数据库存储剪贴板历史。
# 如果没有这个，扩展可能无法保存数据。使用 Recommends 而非 Requires 可以
# 避免在某些最小化安装环境中产生冲突。
Recommends:     libgda-sqlite
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch


# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
Copyous 是一个专为 GNOME 桌面设计的现代化剪贴板管理器。
它允许用户保存复制历史，快速搜索并重新粘贴之前的内容，
极大地提升了办公效率。


# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================
# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# -----------------------------------------------------------
# %autosetup 详解
# -----------------------------------------------------------
# -n myapp-1.0 : 指定解压后的目录名。
#                如果源码包解压出的目录名和 %{name}-%{version} 不一致，必须用这个参数。
#
# -p1          : 指定打补丁时的层级（strip level）。
#                通常对应 git diff 或 diff -u 生成的补丁，默认就是 -p1。
#                如果不写，它通常会尝试自动检测。
#
# 作用：
# 1. 自动解压 Source0 (myapp-1.0.tar.gz)
# 2. 自动进入解压后的目录
# 3. 自动应用 Patch0 和 Patch1
# -----------------------------------------------------------
%autosetup -n myapp-1.0 -p1

# ------------------------------------------------------------------------------
# %build - 编译阶段
# 作用：编译源代码
# ------------------------------------------------------------------------------
# %build
# 对于 GNOME 扩展（纯 JS），通常不需要编译
# 如果是 C/C++ 项目，这里通常是:
# %configure
# make %{?_smp_mflags}

# ------------------------------------------------------------------------------
# %install - 安装阶段
# 作用：将文件复制到临时目录 (%{buildroot})
# ------------------------------------------------------------------------------
%install
# 清理旧的构建目录
rm -rf %{buildroot}

# 1. 创建目标目录结构
# %{_datadir} 通常是 /usr/share
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# 2. 复制文件
# 使用 cp -p 保留文件时间戳和权限
cp -r -p * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/


# ==============================================================================
# 4. 脚本阶段 (Scriptlets)
# ==============================================================================
# %post - 安装后脚本
# 用户执行 dnf install 后运行
%post
# 编译 GSettings 模式，使设置生效
# || : 表示即使出错也不要中断安装
# gsettings list-schemas | grep 'org.gnome.shell.extensions'
# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/ || :

# %postun - 卸载后脚本
# $1 参数含义：0=完全卸载, 1=升级
%postun
if [ $1 -eq 0 ]; then
    # 仅在完全卸载时清理缓存
    glib-compile-schemas %{_datadir}/gnome-shell/extensions/%{uuid}/schemas/ || :
fi


# ==============================================================================
# 5. 文件列表 (%files)
# ==============================================================================
%files
# %license 标记许可证文件，RPM 策略要求必须包含
%license LICENSE

# %doc 标记文档文件
%doc README.md

%{_datadir}/gnome-shell/extensions/%{uuid}

%changelog
%autochangelog
