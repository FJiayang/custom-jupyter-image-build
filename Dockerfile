# Dockerfile

# 步骤 1: 基于一个带有具体 Python 版本的官方镜像
FROM jupyter/minimal-notebook:python-3.11

# 步骤 2: 切换到 root 用户
USER root

# 步骤 3: 安装 uv 及其依赖
# 首先更新包列表并安装 unzip，这是 uv 安装脚本很可能需要的
RUN apt-get update && apt-get install -y unzip && \
    # 然后再执行安装脚本
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv && \
    # 清理 apt 缓存以减小镜像体积
    rm -rf /var/lib/apt/lists/*

# 步骤 4: 复制依赖文件
COPY requirements.txt /tmp/

# 步骤 5: 使用 uv 安装 Python 包
RUN uv pip install --system -r /tmp/requirements.txt && \
    uv cache clean && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# 步骤 6: 切换回普通用户
USER ${NB_UID}
