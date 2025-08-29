#include "UniDeskTextStyle.h"

UniDeskTextStyle::UniDeskTextStyle(QObject* parent)
    : QObject { parent }
{
    _family = QFont().defaultFamily();
#ifdef Q_OS_WIN
    _family = "微软雅黑";
#endif

    QFont caption;
    caption.setFamily(_family);
    caption.setPixelSize(12);
    tiny(caption);

    QFont body;
    body.setFamily(_family);
    body.setPixelSize(13);
    little(body);

    QFont bodyStrong;
    bodyStrong.setFamily(_family);
    bodyStrong.setPixelSize(13);
    bodyStrong.setWeight(QFont::DemiBold);
    littleStrong(bodyStrong);

    QFont subtitle;
    subtitle.setFamily(_family);
    subtitle.setPixelSize(20);
    subtitle.setWeight(QFont::DemiBold);
    small_(subtitle);

    QFont title;
    title.setFamily(_family);
    title.setPixelSize(28);
    title.setWeight(QFont::DemiBold);
    medium(title);

    QFont titleLarge;
    titleLarge.setFamily(_family);
    titleLarge.setPixelSize(40);
    titleLarge.setWeight(QFont::DemiBold);
    large(titleLarge);

    QFont display;
    display.setFamily(_family);
    display.setPixelSize(68);
    display.setWeight(QFont::DemiBold);
    huge_(display);
}

void UniDeskTextStyle::changeFontFamily(const QString& family){
    _family = family;
    emit familyChanged();
    QFont caption;
    caption.setFamily(_family);
    caption.setPixelSize(12);
    tiny(caption);

    QFont body;
    body.setFamily(_family);
    body.setPixelSize(13);
    little(body);

    QFont bodyStrong;
    bodyStrong.setFamily(_family);
    bodyStrong.setPixelSize(13);
    bodyStrong.setWeight(QFont::DemiBold);
    littleStrong(bodyStrong);

    QFont subtitle;
    subtitle.setFamily(_family);
    subtitle.setPixelSize(20);
    subtitle.setWeight(QFont::DemiBold);
    small_(subtitle);

    QFont title;
    title.setFamily(_family);
    title.setPixelSize(28);
    title.setWeight(QFont::DemiBold);
    medium(title);

    QFont titleLarge;
    titleLarge.setFamily(_family);
    titleLarge.setPixelSize(40);
    titleLarge.setWeight(QFont::DemiBold);
    large(titleLarge);

    QFont display;
    display.setFamily(_family);
    display.setPixelSize(68);
    display.setWeight(QFont::DemiBold);
    huge_(display);
    emit tinyChanged();
    emit littleChanged();
    emit littleStrongChanged();
    emit small_Changed();
    emit mediumChanged();
    emit largeChanged();
    emit huge_Changed();
}
