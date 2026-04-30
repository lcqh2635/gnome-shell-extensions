# ==============================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/architektapx/zen-browser/
# 参考文件 https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/purejava/fedora-update
# git clone --depth=1 https://github.com/purejava/fedora-update.git
# ==============================================================================

# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid update-extension@purejava.org

# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-fedora-update
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        50
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        1%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        Update indicator for Fedora. GNOME Shell extension.
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/purejava/fedora-update
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
# 源码：zip 包（GNOME 扩展通常是纯脚本，无需编译）
# https://github.com/purejava/fedora-update/archive/refs/heads/main.zip
Source0:        %{url}/archive/refs/heads/main.zip

# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# 📌 规则：依赖声明行（Requires/BuildRequires/Conflicts 等）必须独占一行，不能有任何行内注释
# ⚠️ 移除不必要的编译依赖！纯 JS 扩展只需要解压+复制
BuildRequires:  unzip
BuildRequires:  gettext
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
BuildRequires:  glib2-devel
# gnome-shell-devel: 提供 GNOME Shell 的开发宏和头文件。
# 虽然不是所有扩展都严格需要，但加上它可以确保环境一致性。
# BuildRequires:  gnome-shell-devel
# --- 运行依赖 (Requires) 用户安装此包时必须存在的软件 ---
# 扩展要求 GNOME Shell 45+ 版本（与 extension metadata 保持一致）✅ 建议匹配扩展实际支持的最低版本
Requires:       gnome-shell >= 48
# --- 推荐依赖 (Recommends) 非强制，但强烈建议安装以获得完整功能 ---
# libgda-sqlite: Copyous 使用 SQLite 数据库存储剪贴板历史。
# 如果没有这个，扩展可能无法保存数据。使用 Recommends 而非 Requires 可以
# 避免在某些最小化安装环境中产生冲突。
# Recommends:     libgda-sqlite
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch

# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
Update indicator for Fedora. GNOME Shell extension.

# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================
# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# 在 ~/rpmbuild/BUILD 目录下创建 update-extension@purejava.org/ 并进入
# %{_builddir}		~/rpmbuild/BUILD		RPM 构建的根目录
# %{buildsubdir}	%{name}-%{version}-build	由 %mkbuilddir 宏设置，用于构建隔离
# %{uuid}		update-extension@purejava.org	你自定义的扩展 UUID
# -c：在当前目录（即 %{_builddir}/%{buildsubdir}）创建新目录 %{uuid}
# -n "%{uuid}"：指定新目录的名称为 update-extension@purejava.org
# 🔑 关键：-T 跳过 rpmuncompress，避免 tar 误解压 zip
# 自动 cd：RPM 会自动 cd 进入这个新目录，后续 %build/%install 都在此执行
%setup -q -c -n "%{uuid}" -T
# 2. 将扁平压缩包解压到当前目录（即 %{uuid}）
# 解压后产生嵌套：update-extension@purejava.org/hidetopbar-extensions.gnome.org-124/
unzip -q -o %{SOURCE0} -d .

# ------------------------------------------------------------------------------
# %build - 编译阶段。在 ~/rpmbuild/BUILD/%{uuid} 目录下执行
# 作用：编译源代码
# ------------------------------------------------------------------------------
%build
# 对于 GNOME 扩展（纯 JS），通常不需要编译
echo "编译阶段：开始编译源代码..."
cd main/fedora-update-main
cp -r -p * ../../
cd ..
rm -rf main

# ------------------------------------------------------------------------------
# %install - 安装阶段
# 作用：将文件复制到临时目录 (%{buildroot})
# ------------------------------------------------------------------------------
%install
# 1. 创建扩展安装目录
# %{_datadir} 通常是 /usr/share
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
# 2. 复制所有扩展文件（排除不需要的构建产物）
cp -r -p * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
# ✅ 如果有 schemas 目录，编译它
if [ -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas ]; then
    glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas
fi

# ==============================================================================
# 5. 文件列表 (%files)
# ==============================================================================
%files
%{_datadir}/gnome-shell/extensions/%{uuid}

%changelog
%autochangelog

# ==============================================================================
# 1. 将 spec 文件放到正确位置
# cp gnome-shell-extension-fedora-update.spec ~/rpmbuild/SPECS/
# 2. 进入 SPECS 目录
# cd ~/rpmbuild/SPECS/
# 🔍 检查 spec 语法
# rpmlint ~/rpmbuild/SPECS/gnome-shell-extension-fedora-update.spec
# 3. 下载源码到 SOURCES（spectool 会自动处理 Source0/1/2）
# spectool -g -R gnome-shell-extension-fedora-update.spec
# ✅ 验证源码是否下载成功
# ls -lh ~/rpmbuild/SOURCES/ | grep add-to-desktop
# 4. 生成 SRPM（源码 RPM）
# rpmbuild -bs gnome-shell-extension-fedora-update.spec
# ✅ 查看生成的 SRPM
# ls -lh ~/rpmbuild/SRPMS/
# 输出示例: gnome-shell-extension-add-to-desktop-16-1.fc44.src.rpm
# 5. 直接生成本地 RPM
# rpmbuild -bb gnome-shell-extension-fedora-update.spec
# 或者将 .src.rpm 源码包编译成 .rpm 安装包
# rpmbuild --rebuild ~/rpmbuild/SRPMS/gnome-shell-extension-add-to-desktop-16-1.fc44.src.rpm
# 生成的 RPM 位置
# ls -lh ~/rpmbuild/RPMS/noarch/
# 输出: gnome-shell-extension-add-to-desktop-16-1.fc44.noarch.rpm
# 安装测试
# sudo dnf install -y ~/rpmbuild/RPMS/noarch/gnome-shell-extension-disable-unredirect-1.2.0-1.fc44.noarch.rpm
# sudo dnf remove -y gnome-shell-extension-desktop-icons-ng
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
