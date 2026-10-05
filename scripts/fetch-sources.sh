#!/bin/bash
# 下载本地构建 server 镜像所需的源码包到 build-sources/（该目录已被 .gitignore 忽略，不入库）
# 中国大陆网络自动走镜像加速；海外直连。
set -e
cd "$(dirname "$0")/.."
mkdir -p build-sources
cd build-sources

dl() { # dl <直连URL> <输出文件名>
    local url="$1" out="$2"
    if [ -s "$out" ]; then echo "已存在 $out，跳过"; return 0; fi
    echo "下载 $out ..."
    if curl -fSL --connect-timeout 20 --retry 2 -o "$out" "$url"; then return 0; fi
    echo "  直连失败，改走镜像 ..."
    curl -fSL --retry 3 -C - -o "$out" "https://ghproxy.net/$url"
}

# 1) OpenH264 v2.6.0（H.264 编解码，MIT/BSD）
dl "https://github.com/cisco/openh264/archive/refs/tags/v2.6.0.tar.gz" openh264-2.6.0.tar.gz

# 2) FFmpeg 8.1.2 源码（取自 Debian 官方源，全球可达且国内速度快）
if [ ! -s ffmpeg-8.1.2.tar.gz ]; then
    dl "http://deb.debian.org/debian/pool/main/f/ffmpeg/ffmpeg_8.1.2.orig.tar.xz" ffmpeg-8.1.2.tar.xz
    echo "转换 xz → gz（构建容器内无 xz 工具）..."
    tar -xf ffmpeg-8.1.2.tar.xz
    tar -czf ffmpeg-8.1.2.tar.gz ffmpeg-8.1.2
    rm -rf ffmpeg-8.1.2 ffmpeg-8.1.2.tar.xz
fi

# 3) Smokescreen（Stripe 开源 SSRF 防护代理）
dl "https://github.com/stripe/smokescreen/archive/refs/heads/master.tar.gz" smokescreen-master.tar.gz

# 4) Datumaro（CVAT 官方数据格式库，钉在 v2.77.0 依赖的提交）
dl "https://github.com/cvat-ai/datumaro/archive/6ade96fa82043fc5bccd59a27218892899fe10ce.zip" datumaro-6ade96f.zip

echo ""
echo "校验 ..."
tar -tzf openh264-2.6.0.tar.gz >/dev/null && echo "  ✓ openh264"
tar -tzf ffmpeg-8.1.2.tar.gz >/dev/null && echo "  ✓ ffmpeg"
tar -tzf smokescreen-master.tar.gz >/dev/null && echo "  ✓ smokescreen"
unzip -tq datumaro-6ade96f.zip >/dev/null && echo "  ✓ datumaro"
echo "全部就绪：$(pwd)"
