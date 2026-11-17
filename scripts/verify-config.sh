#!/usr/bin/env bash
# 在 openwrt 源码目录、make defconfig 之后运行
set -u
CFG=.config
REQ=../config/istoreos-custom.config

echo "===== 目标设备 ====="
if ! grep -qE '^CONFIG_TARGET_amlogic_.*_DEVICE_.*n1.*=y' "$CFG"; then
  echo "::error::未选中 Phicomm N1。当前源码中的 target 与 amlogic 设备如下："
  ls target/linux/
  grep -rhoE '^define Device/[A-Za-z0-9_-]+' target/linux/amlogic/image/ 2>/dev/null | sort -u
  exit 1
fi
grep -E '^CONFIG_TARGET_(BOARD|SUBTARGET|PROFILE)=' "$CFG"

echo "===== 关键选项（缺失即失败） ====="
fail=0
for item in \
  CONFIG_PACKAGE_kmod-nfnetlink-queue=y \
  CONFIG_PACKAGE_kmod-nft-queue=y \
  CONFIG_KERNEL_DEBUG_INFO_BTF=y; do
  if grep -qx "$item" "$CFG"; then echo "OK   $item"; else echo "::error::缺失 $item"; fail=1; fi
done

echo "===== 其他请求选项（缺失仅警告） ====="
miss=0
while IFS= read -r line; do
  case "$line" in CONFIG_*=*) ;; *) continue ;; esac
  if ! grep -qx "$line" "$CFG"; then echo "::warning::未生效 $line"; miss=$((miss+1)); fi
done < "$REQ"
echo "未生效选项数: $miss"

exit $fail
