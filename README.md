在使用本仓库之前，请确保你的系统已安装 GNOME Shell 扩展管理所需的依赖工具。

**1. 安装浏览器连接器**
为了能够通过网页端（extensions.gnome.org）安装和管理扩展，你需要先安装连接器。

- **Fedora / RHEL / CentOS:**
    ```bash
    sudo dnf install gnome-browser-connector
    ```
    注意：虽然部分旧文档可能提及 `chrome-gnome-shell`，但在现代 Fedora 系统中，请优先使用 `gnome-browser-connector` 包。

**2. 启用 Copr 仓库**
在终端中执行以下命令以启用本仓库：
```bash
sudo dnf copr enable lcqh2635/gnome-shell-extensions
```

**3. 搜索与安装**
你可以搜索可用的扩展包（通常以 `gnome-shell-extension-` 开头）：
```bash
dnf search gnome-shell-extension
```
安装你需要的扩展：
```bash
sudo dnf install gnome-shell-extension-<扩展名>
```

**4. 管理与配置**
安装完成后，你可以使用以下两种方式管理扩展：
- **推荐**：安装并打开“Extension Manager”应用，它提供了一个现代化的界面来浏览、安装和配置扩展。
- **备选**：使用“GNOME 扩展”设置或访问 GNOME Extensions 官方网站进行开关和设置。
