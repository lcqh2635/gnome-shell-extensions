# =================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/architektapx/zen-browser/
# 参考文件 https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/stuarthayhurst/alphabetical-grid-extension
# git clone --depth=1 https://github.com/stuarthayhurst/alphabetical-grid-extension.git

# =================================================================
%global debug_package %{nil}
%global uuid AlphabeticalAppGrid@stuarthayhurst

Name:           gnome-shell-extension-alphabetical-grid
Version:        44.0
Release:        1%{?dist}
Summary:        Alphabetically order GNOME's app grid and folders
License:        GPL-3.0-or-later
URL:            https://github.com/stuarthayhurst/alphabetical-grid-extension
# 源码：zip 包（GNOME 扩展通常是纯脚本，无需编译）
Source0:        %{url}/releases/download/v%{version}/%{uuid}.shell-extension.zip

# 📌 规则：依赖声明行（Requires/BuildRequires/Conflicts 等）必须独占一行，不能有任何行内注释
# ⚠️ 移除不必要的编译依赖！纯 JS 扩展只需要解压+复制
BuildRequires:  unzip
# 仅用于 glib-compile-schemas（如果有 schemas）
BuildRequires:  glib2-devel
# 扩展要求 GNOME Shell 44+ 版本（与 extension metadata 保持一致）✅ 建议匹配扩展实际支持的最低版本
Requires:       gnome-shell >= 45
BuildArch:      noarch

%description
Alphabetically order GNOME's application grid and folders.
Built from upstream source for Fedora/Copr.

%prep
# ✅ Flat 结构 zip：创建目标目录 + 直接解压到其中
# -c: 创建目录, -T: 跳过默认补丁处理, -q: 安静模式
# 1. 创建以 UUID 命名的目录，并让 RPM 记录该目录为后续工作区
%setup -q -c -n "%{uuid}"
# 2. 将扁平压缩包解压到当前目录（即 %{uuid}）
unzip -q -o %{SOURCE0} -d .

# %build
# 🎯 纯 JS 扩展无需编译，留空即可
# 如果有 schemas，在这里编译（但通常放在 %install 更稳妥）
# %{?with_schemas: glib-compile-schemas schemas/}

%install
# 创建扩展安装目录
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
# 复制所有扩展文件（排除不需要的构建产物）
cp -r -p * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
# ✅ 如果有 schemas 目录，编译它
if [ -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas ]; then
    glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas
fi

%files
%{_datadir}/gnome-shell/extensions/%{uuid}

%changelog
%autochangelog

# 1. 将 spec 文件放到正确位置
# cp gnome-shell-extension-alphabetical-grid.spec ~/rpmbuild/SPECS/
# 2. 进入 SPECS 目录
# cd ~/rpmbuild/SPECS/
# 🔍 检查 spec 语法
# rpmlint ~/rpmbuild/SPECS/gnome-shell-extension-alphabetical-grid.spec
# 3. 下载源码到 SOURCES（spectool 会自动处理 Source0/1/2）
# spectool -g -R gnome-shell-extension-alphabetical-grid.spec
# ✅ 验证源码是否下载成功
# ls -lh ~/rpmbuild/SOURCES/ | grep AlphabeticalAppGrid
# 4. 生成 SRPM（源码 RPM）
# rpmbuild -bs gnome-shell-extension-alphabetical-grid.spec
# ✅ 查看生成的 SRPM
# ls -lh ~/rpmbuild/SRPMS/
# 输出示例: gnome-shell-extension-alphabetical-grid-44.0-1.fc44.src.rpm
# 5. 直接生成本地 RPM
# rpmbuild -bb gnome-shell-extension-alphabetical-grid.spec
# 或者将 .src.rpm 源码包编译成 .rpm 安装包
# rpmbuild --rebuild ~/rpmbuild/SRPMS/gnome-shell-extension-alphabetical-grid-44.0-1.fc44.src.rpm
# 生成的 RPM 位置
# ls -lh ~/rpmbuild/RPMS/noarch/
# 输出: gnome-shell-extension-alphabetical-grid-44.0-1.fc43.noarch.rpm
# 安装测试
# sudo dnf install -y ~/rpmbuild/RPMS/noarch/gnome-shell-extension-alphabetical-grid-44.0-1.fc44.noarch.rpm
# sudo dnf remove -y gnome-shell-extension-alphabetical-grid
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
# gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
