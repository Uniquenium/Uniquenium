#ifndef UNIDESKTOOLS_H
#define UNIDESKTOOLS_H

#include "stdafx.h"
#include <QQuickItem>
#include <QColor>
#include <QFont>
#include <QUrl>
#include <QRect>
#include <QString>
#include <QList>
#include <QtQml/qqml.h>

class UniDeskTools : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(QList<QString>, familyPaths)
    Q_PROPERTY_AUTO(QList<int>, appFonts)
    QML_NAMED_ELEMENT(UniDeskTools)
    QML_SINGLETON
public:
    explicit UniDeskTools(QQuickItem *parent = nullptr);

    Q_INVOKABLE QColor switchColor(const QColor &normal, const QColor &hover, const QColor &press, const QColor &disable,
                                   bool hovered, bool pressed, bool disabled);
    Q_INVOKABLE void systemCommand(const QString &command);
    Q_INVOKABLE QFont font(const QString &family, int size);
    Q_INVOKABLE bool isSystemColorLight();
    Q_INVOKABLE void web_browse(const QString &url);
    Q_INVOKABLE void setTaskbarVisible(bool vis);
    Q_INVOKABLE QUrl get_wallpaper();
    Q_INVOKABLE QRect desktopGeometry(QQuickWindow *window);
    Q_INVOKABLE void set_wallpaper(const QUrl &path);
    Q_INVOKABLE QUrl fromLocalFile(const QString &path);
    Q_INVOKABLE QVariant applicationFontFamilies();
    Q_INVOKABLE int fontIndex(const QString &familyName);
    Q_INVOKABLE void addFontFamily(const QString &path);
    Q_INVOKABLE void removeFontFamily(const QString &id);
    Q_INVOKABLE QVariant getCustomFonts();
    Q_INVOKABLE bool isValidUrl(const QUrl &url);

signals:
    void customFontsChanged();
};

#endif // UNIDESKTOOLS_H
