# 空间天气（Space Weather）

面向「日—地」链路的空间天气态势感知应用：汇总 NOAA SWPC / NASA SDO 等公开数据，把太阳活动、太阳风、地磁场与电离层/极光信息放在同一套界面里查看。

## 功能概览

- **首页总览**：太阳活动、太阳风、地磁、电离层四块态势卡片，可跳转专题页
- **太阳活动**：多波段太阳图像（SDO/AIA、HMI、LASCO），支持放大查看、复制链接与保存原图
- **太阳风**：速度、密度、动压、IMF 等关键参数与影响评估
- **地磁场**：Kp / Dst、等级标尺与短期预报
- **电离层与极光**：TEC、闪烁等级、极光椭圆等（部分指标由地磁状态推导）

数据按固定间隔自动刷新，也可手动刷新。

## 数据来源

- [NOAA Space Weather Prediction Center](https://www.swpc.noaa.gov/)（太阳风、地磁、X 射线、活动区等）
- [NASA SDO](https://sdo.gsfc.nasa.gov/)（多波段太阳图像）
- [NASA DONKI](https://kauai.ccmc.gsfc.nasa.gov/DONKI/)（CME 事件）

## 技术栈

- Flutter / Dart 跨平台桌面与移动端
- 分层结构：Service → Repository → ViewModel → UI
- Material 3 浅色 / 深色主题

## 运行

```bash
flutter pub get
flutter run
```

选择本机可用的 Linux / Windows / macOS / 移动设备即可。
