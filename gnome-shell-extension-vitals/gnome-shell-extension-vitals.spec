# ==============================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/architektapx/zen-browser/
# 参考 spec 文件：
# https://github.com/openSUSE/Customize-IBus/blob/main/gnome-shell-extension-customize-ibus.spec
# https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/icedman/search-light
# git clone --depth=1 https://github.com/icedman/search-light.git
# ==============================================================================

# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid Vitals@CoreCoding.com

# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-vitals
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        76.0.0
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        1%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        A glimpse into your computer's temperature, voltage, fan speed, memory usage and CPU load.
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/corecoding/Vitals
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
# 源码：zip 包（GNOME 扩展通常是纯脚本，无需编译）
# https://github.com/corecoding/Vitals/releases/download/v76.0.0/vitals.zip
Source0:        %{url}/releases/download/v%{version}/vitals.zip

# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# 📌 规则：依赖声明行（Requires/BuildRequires/Conflicts 等）必须独占一行，不能有任何行内注释
# 核心构建工具
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
BuildRequires:  glib2-devel
# 处理 .po/.mo 翻译文件
BuildRequires:  gettext
BuildRequires:  unzip
# 依赖 GNOME Shell 版本 (按需调整)
BuildRequires:  gnome-shell >= 45
# --- 运行时依赖 (Requires) ---
Requires:       gnome-shell
Requires:       glib2
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch

# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
A glimpse into your computer's temperature, voltage, fan speed, memory usage, processor load, system resources, network speed and storage stats. 
This is a one stop shop to monitor all of your vital sensors. Uses asynchronous polling to provide a smooth user experience. Feature requests or bugs? Please use GitHub.",


# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================
# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# 在 ~/rpmbuild/BUILD 目录下创建 hidetopbar@mathieu.bidon.ca/ 并进入
# %{_builddir}		~/rpmbuild/BUILD		RPM 构建的根目录
# %{buildsubdir}	%{name}-%{version}-build	由 %mkbuilddir 宏设置，用于构建隔离
# %{uuid}		hidetopbar@mathieu.bidon.ca	你自定义的扩展 UUID
# -c：在当前目录（即 %{_builddir}/%{buildsubdir}）创建新目录 %{uuid}
# -n "%{uuid}"：指定新目录的名称为 hidetopbar@mathieu.bidon.ca
# 🔑 关键：-T 跳过 rpmuncompress，避免 tar 误解压 zip
# 自动 cd：RPM 会自动 cd 进入这个新目录，后续 %build/%install 都在此执行
%setup -q -c -n "%{uuid}" -T
# 2. 将扁平压缩包解压到当前目录（即 %{uuid}）
# 解压后产生嵌套：hidetopbar@mathieu.bidon.ca/hidetopbar-extensions.gnome.org-124/
unzip -q -o %{SOURCE0} -d .

# ------------------------------------------------------------------------------
# %build - 编译阶段。在 ~/rpmbuild/BUILD/%{uuid} 目录下执行
# 作用：编译源代码
# ------------------------------------------------------------------------------
%build
# 对于 GNOME 扩展（纯 JS），通常不需要编译
echo "编译阶段：开始编译源代码..."


# ------------------------------------------------------------------------------
# %install - 安装阶段
# 作用：将文件复制到临时目录 (%{buildroot})
# ------------------------------------------------------------------------------
%install
# 1. 创建扩展安装目录
# %{_datadir} 通常是 /usr/share
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
# 2. 复制所有扩展文件（排除不需要的构建产物）
# 🔑 关键：从嵌套目录复制，而不是当前目录
cp -r -p * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
# ✅ 如果有 schemas 目录，编译它
if [ -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas ]; then
    glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas
fi

# ==============================================================================
# 5. 文件列表 (%files)
# 💡 RPM 打包原则：任何进入 %{buildroot} 的文件，必须在 %files 中显式声明，否则构建失败。
# ==============================================================================
%files
# --- 1. GNOME Shell 扩展主目录 ---
%dir %{_datadir}/gnome-shell/extensions/%{uuid}
%{_datadir}/gnome-shell/extensions/%{uuid}/*
# --- 2. 【新增】全局 GSettings Schema 文件 ---
# 【通用声明】匹配标准 GNOME 扩展命名空间的所有 schema 文件
%{_datadir}/glib-2.0/schemas/org.gnome.shell.extensions.*.gschema.xml

%changelog
%autochangelog

# ==============================================================================
# 1. 将 spec 文件放到正确位置
# cp gnome-shell-extension-vitals.spec ~/rpmbuild/SPECS/
# 2. 进入 SPECS 目录
# cd ~/rpmbuild/SPECS/
# 🔍 检查 spec 语法
# rpmlint ~/rpmbuild/SPECS/gnome-shell-extension-vitals.spec
# 3. 下载源码到 SOURCES（spectool 会自动处理 Source0/1/2）
# spectool -g -R gnome-shell-extension-vitals.spec
# ✅ 验证源码是否下载成功
# ls -lh ~/rpmbuild/SOURCES/ | grep add-to-desktop
# 4. 生成 SRPM（源码 RPM）
# rpmbuild -bs gnome-shell-extension-vitals.spec
# ✅ 查看生成的 SRPM
# ls -lh ~/rpmbuild/SRPMS/
# 5. 直接生成本地 RPM
# rpmbuild -bb gnome-shell-extension-vitals.spec
# 生成的 RPM 位置
# ls -lh ~/rpmbuild/RPMS/noarch/
# 安装测试
# sudo dnf install -y ~/rpmbuild/RPMS/noarch/gnome-shell-extension-vitals-*.fc44.noarch.rpm
# sudo dnf remove -y gnome-shell-extension-vitals
# gnome-session-quit --logout

    # dnf list gnome-shell-extension*
    # gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
    # gsettings list-schemas
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # gsettings list-recursively org.gnome.desktop.interface
    # 列出所有系统级扩展
    # gnome-extensions list --system
    # 查看所有系统级扩展的文件目录
    # nautilus admin:/usr/share/gnome-shell/extensions

# 启用扩展（需重启 GNOME Shell 或按 Alt+F2 输入 'r'）
# gnome-extensions enable add-to-desktop@tommimon.github.com
# ==============================================================================
