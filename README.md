# 自动化 Jupyter Notebook 环境

本仓库使用 Docker 和 GitHub Actions 自动构建一个包含自定义 Python 依赖的 Jupyter Notebook 环境。

## ✨ 功能特性

-   **Dockerfile 定义**: 环境配置代码化、版本化。
-   **依赖管理**: 通过 `requirements.txt` 轻松管理 Python 包。
-   **自动化构建**: 每次推送到 `main` 分支时，GitHub Actions 自动构建并发布新的 Docker 镜像到 [GitHub Container Registry (ghcr.io)](https://ghcr.io)。
-   **轻松部署**: 使用 `docker-compose.yml` 在任何支持 Docker 的服务器上一键部署。

## 🚀 如何使用

### 一、初始化设置

1.  **Fork 或克隆本仓库**到你自己的 GitHub 账户下。

2.  **自定义依赖**: 打开 `requirements.txt` 文件，添加或删除你需要的 Python 包。

3.  **提交并推送**: 将你的修改提交并推送到 `main` 分支。
    ```bash
    git add .
    git commit -m "feat: Update Python packages"
    git push origin main
    ```

4.  **检查 Actions**: 进入你的 GitHub 仓库页面，点击 "Actions" 标签。你应该能看到一个名为 "Build and Push Jupyter Docker Image" 的工作流正在运行。成功后，你的自定义镜像就已经发布到 `ghcr.io` 了。

### 二、在服务器上部署

在你自己的服务器（如个人电脑、NAS 等）上执行以下步骤：

1.  **安装 Docker 和 Docker Compose**。

2.  **创建数据目录**: 在服务器上创建一个用于存放你的 Notebook 和数据的文件夹。
    ```bash
    mkdir -p /volume2/docker/my-jupyter-data
    ```

3.  **创建 `docker-compose.yml` 文件**: 将本仓库中的 `docker-compose.yml` 文件复制到你的服务器上。

4.  **修改 `docker-compose.yml`**:
    *   **`image`**: 将 `ghcr.io/your-github-username/your-repo-name:latest` 修改为你自己的镜像地址。例如：`ghcr.io/octocat/my-jupyter:latest`。
    *   **`volumes`**: 确保左侧的路径是你刚刚创建的数据目录。
    *   **`environment`**:
        *   在服务器上运行 `id -u` 和 `id -g`，并将结果填入 `NB_UID` 和 `NB_GID`，以避免文件权限问题。
        *   设置一个强密码给 `JUPYTER_TOKEN`。

5.  **启动容器**: 在 `docker-compose.yml` 所在的目录下，运行以下命令：
    ```bash
    # 拉取你在 ghcr.io 上构建的最新镜像
    docker-compose pull

    # 以后台模式启动容器
    docker-compose up -d
    ```

6.  **访问 Jupyter**: 打开浏览器，访问 `http://<你的服务器IP>:43239`，然后输入你设置的密码即可。

### 三、更新环境

当你需要添加或更新 Python 包时：

1.  修改本地的 `requirements.txt` 文件。
2.  `git commit` 和 `git push` 推送到 `main` 分支。
3.  等待 GitHub Actions 完成构建。
4.  在你的服务器上，再次运行 `docker-compose pull` 和 `docker-compose up -d`，服务就会用最新的镜像重启。你的所有数据都因为挂载了卷而保持不变。
