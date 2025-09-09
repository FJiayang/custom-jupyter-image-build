# Dockerfile

# 步骤 1: 基于一个带有具体 Python 版本的官方镜像
FROM jupyter/minimal-notebook:python-3.11

ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8
# 步骤 2: 切换到 root 用户
USER root

# 步骤 3: 安装 uv 及其依赖 (合并为单层以优化)
RUN apt-get update && apt-get install -y unzip locales fonts-wqy-zenhei iputils-ping && \
    # 执行安装脚本
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    # 使用正确的源路径移动 uv
    cp /home/jovyan/.local/bin/* /usr/local/bin/ && \
    # 清理 apt 缓存
    rm -rf /var/lib/apt/lists/*

# 更新系统时区配置，供系统命令和工具使用
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # 配置并生成中文 locale
    sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# 步骤 4: 复制依赖文件
COPY requirements.txt /tmp/

# 步骤 5: 使用 uv 安装 Python 包
RUN uv pip install --system -r /tmp/requirements.txt && \
    uv cache clean && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    uv --version && uvx --version

# 步骤 6: 切换回普通用户
USER ${NB_UID}
