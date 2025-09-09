# Dockerfile

# 步骤 1: 基于一个带有具体 Python 版本的官方镜像，以保证环境可复现
FROM jupyter/minimal-notebook:python-3.11

# 步骤 2: 切换到 root 用户，以便安装系统包和修改权限
USER root

# 步骤 3: 复制依赖文件到容器中
COPY requirements.txt /tmp/

# 步骤 4: 使用 mamba (比 conda 更快) 安装依赖，然后清理缓存以减小镜像体积
# mamba install: 从文件安装依赖
# mamba clean: 清理无用包和缓存
# fix-permissions: Jupyter 官方提供的脚本，用于修复因 root 安装导致的文件权限问题
RUN mamba install --yes --file /tmp/requirements.txt && \
    mamba clean -afy && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# 步骤 5: 切换回默认的非 root 用户 jovyan
USER ${NB_UID}
