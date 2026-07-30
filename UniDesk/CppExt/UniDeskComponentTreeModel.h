#include "stdafx.h"
#include <QAbstractItemModel>
#include <QQmlEngine>
#include <QVariantMap>
#include <QList>
#include <QHash>
#include <QString>
#include <QModelIndex>

class UniDeskComponentTreeModel : public QAbstractItemModel {
    Q_OBJECT
    Q_PROPERTY_AUTO_P(int, count)
    Q_PROPERTY_AUTO_P(QString, pageId)
    QML_NAMED_ELEMENT(UniDeskComponentTreeModel)

public:
    struct Node;

    explicit UniDeskComponentTreeModel(QObject *parent = nullptr);
    ~UniDeskComponentTreeModel() override;

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // ===== QML兼容API =====
    Q_INVOKABLE void append(const QVariantMap &data);
    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE void removeById(const QString &identification);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE QString getIdentification(int row) const;
    Q_INVOKABLE int findRow(const QString &identification) const;
    Q_INVOKABLE bool contains(const QString &identification) const;
    Q_INVOKABLE void update(const QVariantMap &data);
    Q_INVOKABLE void reparentAll();

private:
    struct Node {
        QString identification;
        QString name;
        QString type;
        QString parentId;
        QList<Node*> children;
        Node* parent = nullptr;
        Node() = default;
        ~Node() { qDeleteAll(children); }
    };

    QList<Node*> m_nodes;
    QHash<QString, Node*> m_idToNode;

    int calcFlatCount() const;
    Node* findNode(const QString &identification) const;
    void removeNode(Node* node);
    void flattenNodes(QList<Node*> &out) const;
    QModelIndex findIndexById(const QString &identification) const;
    void emitCountChanged();
};