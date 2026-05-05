# ==============================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/architektapx/zen-browser/
# 参考 spec 文件：
# https://github.com/openSUSE/Customize-IBus/blob/main/gnome-shell-extension-customize-ibus.spec
# https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/hermes83/compiz-alike-magic-lamp-effect
# git clone --depth=1 https://github.com/hermes83/compiz-alike-magic-lamp-effect.git
# ==============================================================================

# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 项目名称
%global projectname compiz-alike-magic-lamp-effect
# 指定源码 commit（确保构建可复现）
# 上游已经在更新仓库源代码，只是没有用 GitHub Releases 的情况下，使用 commit snapshot（Fedora 官方推荐）
# https://github.com/hermes83/compiz-alike-magic-lamp-effect/commits/master/
%global commit eb2aff167146b0a9eca780ad0fe30eafaab3a26f
%global shortcommit %(c=%{commit}; echo ${c:0:7})
# 扩展 UUID（必须与 metadata.json 一致）
%global uuid compiz-alike-magic-lamp-effect@hermes83.github.com

# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-compiz-magic
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        25
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release: 	1.git%{shortcommit}%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        Compiz alike magic lamp effect for GNOME Shell
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/hermes83/compiz-alike-magic-lamp-effect
# 源代码压缩包。可以指向 GitHub 的 Release 或使用 commit snapshot 提供的压缩包
# 方式1：使用 Release 中的 tag (优先选择)
# 方式2：如果仓库没有发布 Release 或者 Release 太老不更新了，则使用 commit snapshot 提供的压缩包
Source0: 	%{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz
# 架构，noarch 表示此包不包含任何与 CPU 架构相关的二进制文件，它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch

# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# 构建依赖（用于 schema 处理）
# glib2: 提供 glib-compile-schemas 工具
# 📌 规则：依赖声明行（Requires/BuildRequires/Conflicts 等）必须独占一行，不能有任何行内注释
BuildRequires:  glib2
# 运行依赖（必须与 metadata.json 中 shell-version 对齐）
Requires:       gnome-shell >= 45
# scriptlet 依赖（用于 glib schema 编译）
Requires(post): glib2
Requires(postun): glib2

# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
This extension adds a Compiz-like magic lamp minimize effect to GNOME Shell.

# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================
# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# 在 ~/rpmbuild/BUILD 目录下创建 compiz-alike-magic-lamp-effect@hermes83.github.com/ 并进入
# %{_builddir}		~/rpmbuild/BUILD		RPM 构建的根目录
# %{buildsubdir}	%{name}-%{version}-build	由 %mkbuilddir 宏设置，用于构建隔离
# %{uuid}		compiz-alike-magic-lamp-effect@hermes83.github.com	你自定义的扩展 UUID
# -c：在当前目录（即 %{_builddir}/%{buildsubdir}）创建新目录 %{uuid}
# -n "%{uuid}"：指定新目录的名称为 compiz-alike-magic-lamp-effect@hermes83.github.com
# 自动 cd：RPM 会自动 cd 进入这个新目录，后续 %build/%install 都在此执行

# 自动解压 tar.gz，并进入源码目录
%autosetup -n %{projectname}-%{commit}

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
install -dm 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
# 拷贝扩展文件
cp -a * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# ==============================================================================
# 4. 脚本阶段 (Scriptlets)
# ==============================================================================
# %post - 安装后脚本
# 用户执行 dnf install 后运行
%post
%glib2_schemas_post

# %postun - 卸载后脚本
%postun
%glib2_schemas_postun

# ==============================================================================
# 5. 文件列表 (%files)
# 💡 RPM 打包原则：任何进入 %{buildroot} 的文件，必须在 %files 中显式声明，否则构建失败。
# ==============================================================================
%files
# 扩展目录
%{_datadir}/gnome-shell/extensions/%{uuid}
# schema 文件（精确匹配）
%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/*.xml

%changelog
%autochangelog

# ==============================================================================
# 1. 将 spec 文件放到正确位置
# cp gnome-shell-extension-compiz-magic.spec ~/rpmbuild/SPECS/
# 2. 进入 SPECS 目录
# cd ~/rpmbuild/SPECS/
# 🔍 检查 spec 语法
# rpmlint ~/rpmbuild/SPECS/gnome-shell-extension-compiz-magic.spec
# 3. 下载源码到 SOURCES（spectool 会自动处理 Source0/1/2）源码存放目录为 ~/rpmbuild/SOURCES/
# spectool -g -R gnome-shell-extension-compiz-magic.spec
# ✅ 验证源码是否下载成功
# ls -lh ~/rpmbuild/SOURCES/ | grep master.zip
# 4. 生成 SRPM（源码 RPM）
# rpmbuild -bs gnome-shell-extension-compiz-magic.spec
# ✅ 查看生成的 SRPM
# ls -lh ~/rpmbuild/SRPMS/
# 输出示例: gnome-shell-extension-compiz-magic-*.fc44.src.rpm
# 5. 直接生成本地 RPM
# rpmbuild -bb gnome-shell-extension-compiz-magic.spec
# 或者将 .src.rpm 源码包编译成 .rpm 安装包
# rpmbuild --rebuild ~/rpmbuild/SRPMS/gnome-shell-extension-compiz-magic-*.fc44.src.rpm
# 生成的 RPM 位置
# ls -lh ~/rpmbuild/RPMS/noarch/
# 输出: gnome-shell-extension-compiz-magic-*.fc44.noarch.rpm
# 安装测试
# sudo dnf install -y ~/rpmbuild/RPMS/noarch/gnome-shell-extension-compiz-magic-*.fc44.noarch.rpm
# sudo dnf remove -y gnome-shell-extension-compiz-magic
# dnf list gnome-shell-extension-compiz-magic
# dnf search gnome-shell-extension-compiz-magic
# gnome-session-quit --logout
# 启用扩展（需重启 GNOME Shell 或按 Alt+F2 输入 'r'）
# gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com

# 列出所有系统级扩展
# gnome-extensions list --system
# ls /usr/share/glib-2.0/schemas | grep 'org.gnome.shell.extensions'
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
# gsettings list-schemas | grep 'org.gnome.shell.extensions'
# gsettings list-recursively org.gnome.shell.extensions.com.github.hermes83.compiz-alike-magic-lamp-effect
# gsettings reset-recursively org.gnome.shell.extensions.com.github.hermes83.compiz-alike-magic-lamp-effect
# ==============================================================================
