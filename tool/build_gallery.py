"""Rebuild the Markdown screenshot index and overview from verified app captures."""
from pathlib import Path
import math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'docs/screenshots'
NAMES = [
    ('频道菜单', '/home + options'), ('频道首页', '/home'), ('欢迎页', '/welcome'),
    ('登录', '/login'), ('个人二维码', '/qr'), ('选择账号', '/accounts'),
    ('注册', '/signup'), ('地址选择', '/address'), ('头像选择弹层', '/complete-profile + photos'),
    ('完善资料', '/complete-profile'), ('验证码', '/passcode'), ('个人资料菜单', '/profile + options'),
    ('个人中心', '/profile'), ('语言偏好', '/language'), ('联系人', '/contacts'),
    ('启用联系人', '/contacts-permission'), ('邀请朋友', '/invite'), ('频道设置', '/chat-settings'),
    ('主题设置', '/theme'), ('通知列表', '/notifications'), ('收藏空状态', '/starred'),
    ('照片预览', '/photo-preview'), ('相机演示', '/camera'), ('视频接听状态', '/incoming-call + accept'),
    ('视频来电', '/incoming-call'), ('展开频道', '/channels-expanded'), ('新建频道', '/new-channel'),
    ('聊天', '/chat'), ('语音通话', '/voice-call'), ('消息长按菜单', '/chat + options'),
    ('已收藏消息', '/starred'), ('深色主题', '/theme + Tinted Blue'), ('通话列表', '/calls'),
    ('编辑资料', '/edit-profile'), ('隐私与安全', '/privacy'), ('通知偏好', '/notification-settings'),
    ('群组成员', '/members'), ('共享媒体', '/media'), ('附近的人', '/nearby'),
    ('找回密码', '/forgot'), ('修改密码', '/reset'), ('归档会话', '/archived'), ('创建频道后的首页', '/home'),
]
files = sorted(SHOTS.glob('[0-9][0-9]_*.png'))
if len(files) != len(NAMES):
    raise SystemExit(f'Expected {len(NAMES)} app captures, found {len(files)}')
font = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 16)

def sheet(chosen, columns, width, output):
    tile_h = round(width * 2340 / 1080)
    gap, label_h = 18, 38
    result = Image.new('RGB', (columns*(width+gap)+gap,
        math.ceil(len(chosen)/columns)*(tile_h+label_h+gap)+gap), '#ECEEF2')
    draw = ImageDraw.Draw(result)
    for i, file in enumerate(chosen):
        x = gap+(i%columns)*(width+gap)
        y = gap+(i//columns)*(tile_h+label_h+gap)
        image = Image.open(file).convert('RGB')
        image.thumbnail((width, tile_h), Image.Resampling.LANCZOS)
        result.paste(image,(x,y))
        number = int(file.name[:2])
        draw.text((x,y+tile_h+8), f'{number:02}  {NAMES[number-1][0]}', font=font, fill='#272A32')
    result.save(output, quality=92)

featured = [3, 2, 28, 13, 19, 15, 25, 18]
by_number = {int(f.name[:2]): f for f in files}
sheet([by_number[n] for n in featured], 4, 260, SHOTS/'overview.jpg')
sheet(files, 7, 180, SHOTS/'all_screens.jpg')
lines = ['# Amia · 界面截图', '',
    f'共 {len(files)} 张实际 Android 应用界面和交互状态截图，覆盖 30 个 Pixso 参考画板及补充页面。', '',
    '图片由 Flutter 集成测试从 Android 模拟器采集，尺寸 1080 × 2340。保留原始 PNG；总览图只用于快速浏览。', '',
    '## 主要界面总览', '', '![主要界面](screenshots/overview.jpg)', '',
    '## 全部界面', '', '| 编号 | 页面 / 状态 | 访问路径 | 预览 |', '|---|---|---|---|']
for file, (name, route) in zip(files, NAMES):
    lines.append(f'| {file.name[:2]} | [{name}](screenshots/{file.name}) | `{route}` | <img src="screenshots/{file.name}" width="130" alt="{name}"> |')
lines += ['', '## Pixso 原稿对照', '',
    '参考文档：**Amia - Messaging App UI Kit**，页面：**Design**，共 30 个 375 × 812 画板。', '',
    '原始画板使用其设计编号命名，见 [原稿目录](design/)。应用截图 01–30 对应相同设计编号；其中 12 是个人菜单状态，24 是已接听视频状态。', '',
    '![Pixso 原稿总览](design/overview.jpg)', '',
    '## 重新采集', '', '```powershell',
    'flutter drive --driver=test_driver/screenshots.dart --target=integration_test/app_test.dart -d <模拟器ID>',
    'python tool/build_gallery.py', '```', '',
    '截图脚本使用内存状态。登录/注册、静态地图、通话、联系人等功能的实际范围见 [项目说明](项目说明.md)。', '']
(ROOT/'docs/界面截图.md').write_text('\n'.join(lines), encoding='utf-8')
print(f'Built screenshot index and 2 overview images for {len(files)} captures.')
