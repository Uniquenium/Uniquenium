#include "UniDeskComponentTreeModel.h"
#include <algorithm>


UniDeskComponentTreeModel::UniDeskComponentTreeModel(QObject *parent)
    : QAbstractItemModel(parent)
{
}

UniDeskComponentTreeModel::~UniDeskComponentTreeModel()
{
    qDeleteAll(m_nodes);
}
// ===== QAbstractItemModel接口 =====

QModelIndex UniDeskComponentTreeModel::index(int row, int column, const QModelIndex &parent) const
{
    if (row < 0 || column != 0)
        return QModelIndex();

    Node* parentNode = nullptr;
    if (parent.isValid()) {
        parentNode = static_cast<Node*>(parent.internalPointer());
    }

    const QList<Node*>& children = parentNode ? parentNode->children : m_nodes;
    if (row >= children.size())
        return QModelIndex();

    return createIndex(row, column, children[row]);
}

QModelIndex UniDeskComponentTreeModel::parent(const QModelIndex &child) const
{
    if (!child.isValid())
        return QModelIndex();

    Node* node = static_cast<Node*>(child.internalPointer());
    if (!node || !node->parent)
        return QModelIndex();

    Node* grandParent = node->parent->parent;
    const QList<Node*>& siblings = grandParent ? grandParent->children : m_nodes;
    int row = siblings.indexOf(node->parent);
    if (row < 0)
        return QModelIndex();

    return createIndex(row, 0, node->parent);
}

void UniDeskComponentTreeModel::reparentAll()
{
    // 收集所有需要重新挂接的节点
    QList<Node*> nodesToReparent;
    for (Node* node : m_nodes) {
        // 深度优先收集所有节点
        QList<Node*> stack;
        stack.append(node);
        while (!stack.isEmpty()) {
            Node* current = stack.takeLast();
            nodesToReparent.append(current);
            for (Node* child : current->children)
                stack.append(child);
        }
    }

    // 先将所有节点从父节点移除，暂存
    for (Node* node : nodesToReparent) {
        if (node->parent) {
            QList<Node*>& siblings = node->parent->children;
            int idx = siblings.indexOf(node);
            if (idx >= 0) {
                beginRemoveRows(createIndex(0, 0, node->parent), idx, idx);
                siblings.removeAt(idx);
                endRemoveRows();
            }
            node->parent = nullptr;
        } else {
            int idx = m_nodes.indexOf(node);
            if (idx >= 0) {
                beginRemoveRows(QModelIndex(), idx, idx);
                m_nodes.removeAt(idx);
                endRemoveRows();
            }
        }
    }

    // 根据parentId重新挂接
    for (Node* node : nodesToReparent) {
        Node* newParent = node->parentId.isEmpty() ? nullptr : m_idToNode.value(node->parentId, nullptr);
        if (newParent && newParent != node) {
            beginInsertRows(createIndex(0, 0, newParent), newParent->children.size(), newParent->children.size());
            node->parent = newParent;
            newParent->children.append(node);
            endInsertRows();
        } else {
            beginInsertRows(QModelIndex(), m_nodes.size(), m_nodes.size());
            node->parent = nullptr;
            m_nodes.append(node);
            endInsertRows();
        }
    }

    emitCountChanged();
}



int UniDeskComponentTreeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.column() > 0)
        return 0;

    Node* parentNode = nullptr;
    if (parent.isValid())
        parentNode = static_cast<Node*>(parent.internalPointer());

    return parentNode ? parentNode->children.size() : m_nodes.size();
}

int UniDeskComponentTreeModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 1;
}

QVariant UniDeskComponentTreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    Node* node = static_cast<Node*>(index.internalPointer());
    if (!node)
        return QVariant();

    switch (role) {
    case Qt::DisplayRole:
        return node->name;
    case Qt::UserRole + 1:  // identification
        return node->identification;
    case Qt::UserRole + 2:  // type
        return node->type;
    case Qt::UserRole + 3:  // parentId
        return node->parentId;
    case Qt::UserRole + 4:  // z
        return node->z;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> UniDeskComponentTreeModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles.insert(Qt::DisplayRole, "display");
    roles.insert(Qt::UserRole + 1, "identification");
    roles.insert(Qt::UserRole + 2, "type");
    roles.insert(Qt::UserRole + 3, "parentId");
 roles.insert(Qt::UserRole + 4, "z");
    return roles;
}

// ===== QML兼容API =====

void UniDeskComponentTreeModel::append(const QVariantMap &data)
{
    QString id = data.value("identification").toString();
    if (id.isEmpty())
        return;

    // 已存在则先移除
    if (m_idToNode.contains(id)) {
        removeById(id);
    }

    Node* node = new Node();
    node->identification = id;
    node->name = data.value("name").toString();
    node->type = data.value("type").toString();
    node->parentId = data.value("parentId").toString();
    node->z = data.value("z").toDouble();

    // 查找父节点
    Node* parentNode = nullptr;
    if (!node->parentId.isEmpty() && m_idToNode.contains(node->parentId)) {
        parentNode = m_idToNode.value(node->parentId);
    }

    if (parentNode) {
        // 添加为子节点
        beginInsertRows(createIndex(0, 0, parentNode), parentNode->children.size(), parentNode->children.size());
        node->parent = parentNode;
        parentNode->children.append(node);
        endInsertRows();
    } else {
        // 添加为根节点
        beginInsertRows(QModelIndex(), m_nodes.size(), m_nodes.size());
        node->parent = nullptr;
        m_nodes.append(node);
        endInsertRows();
    }

    m_idToNode.insert(id, node);
    sortSiblings(node);
    emitCountChanged();
}

void UniDeskComponentTreeModel::remove(int row)
{
    if (row < 0 || row >= calcFlatCount())
        return;

    QList<Node*> flatList;
    flattenNodes(flatList);
    if (row < flatList.size()) {
        removeNode(flatList[row]);
    }
}

void UniDeskComponentTreeModel::removeById(const QString &identification)
{
    if (!m_idToNode.contains(identification))
        return;
    removeNode(m_idToNode.value(identification));
}

void UniDeskComponentTreeModel::clear()
{
    if (m_nodes.isEmpty())
        return;

    beginResetModel();
    qDeleteAll(m_nodes);
    m_nodes.clear();
    m_idToNode.clear();
    endResetModel();
    emitCountChanged();
}

int UniDeskComponentTreeModel::calcFlatCount() const
{
    int count = 0;
    for (Node* node : m_nodes) {
        // 递归计数所有节点
        QList<Node*> stack;
        stack.append(node);
        while (!stack.isEmpty()) {
            Node* current = stack.takeLast();
            count++;
            for (Node* child : current->children)
                stack.append(child);
        }
    }
    return count;
}

QVariantMap UniDeskComponentTreeModel::get(int row) const
{
    QVariantMap result;
    QList<Node*> flatList;
    flattenNodes(flatList);
    if (row >= 0 && row < flatList.size()) {
        Node* node = flatList[row];
        result["identification"] = node->identification;
        result["name"] = node->name;
        result["type"] = node->type;
        result["parentId"] = node->parentId;
    }
    return result;
}

QString UniDeskComponentTreeModel::getIdentification(int row) const
{
    QList<Node*> flatList;
    flattenNodes(flatList);
    if (row >= 0 && row < flatList.size())
        return flatList[row]->identification;
    return QString();
}

int UniDeskComponentTreeModel::findRow(const QString &identification) const
{
    QList<Node*> flatList;
    flattenNodes(flatList);
    for (int i = 0; i < flatList.size(); ++i) {
        if (flatList[i]->identification == identification)
            return i;
    }
    return -1;
}

bool UniDeskComponentTreeModel::contains(const QString &identification) const
{
    return m_idToNode.contains(identification);
}

void UniDeskComponentTreeModel::update(const QVariantMap &data)
{
    QString id = data.value("identification").toString();
    if (id.isEmpty() || !m_idToNode.contains(id))
        return;

    Node* node = m_idToNode.value(id);
    if (data.contains("name"))
        node->name = data.value("name").toString();
    if (data.contains("type"))
        node->type = data.value("type").toString();
    if (data.contains("z"))
        node->z = data.value("z").toDouble();

    // 如果parentId改变，需要移动节点
    QString newParentId = data.value("parentId").toString();
    if (newParentId != node->parentId) {
        // 从当前父节点移除
        if (node->parent) {
            QList<Node*>& siblings = node->parent->children;
            int idx = siblings.indexOf(node);
            if (idx >= 0) {
                beginRemoveRows(createIndex(0, 0, node->parent), idx, idx);
                siblings.removeAt(idx);
                endRemoveRows();
            }
        } else {
            int idx = m_nodes.indexOf(node);
            if (idx >= 0) {
                beginRemoveRows(QModelIndex(), idx, idx);
                m_nodes.removeAt(idx);
                endRemoveRows();
            }
        }

        node->parentId = newParentId;

        // 添加到新父节点
        Node* newParent = newParentId.isEmpty() ? nullptr : m_idToNode.value(newParentId, nullptr);
        if (newParent) {
            beginInsertRows(createIndex(0, 0, newParent), newParent->children.size(), newParent->children.size());
            node->parent = newParent;
            newParent->children.append(node);
            endInsertRows();
        } else {
            beginInsertRows(QModelIndex(), m_nodes.size(), m_nodes.size());
            node->parent = nullptr;
            m_nodes.append(node);
            endInsertRows();
        }
        sortSiblings(node);
    } else {
        // 仅更新数据
        QModelIndex idx = findIndexById(id);
        if (idx.isValid()) {
            emit dataChanged(idx, idx);
        }
        if (data.contains("z")) {
            sortSiblings(node);
        }
    }
}

void UniDeskComponentTreeModel::setZ(const QString &identification, qreal z)
{
    Node* node = m_idToNode.value(identification, nullptr);
    if (!node)
        return;
    if (qFuzzyCompare(node->z, z))
        return;
    node->z = z;
    sortSiblings(node);
    QModelIndex idx = findIndexById(identification);
    if (idx.isValid())
        emit dataChanged(idx, idx);
}

// ===== Page属性 =====

// ===== 辅助函数 =====

UniDeskComponentTreeModel::Node* UniDeskComponentTreeModel::findNode(const QString &identification) const
{
    return m_idToNode.value(identification, nullptr);
}

void UniDeskComponentTreeModel::removeNode(Node* node)
{
    if (!node)
        return;

    // 先递归移除子节点
    while (!node->children.isEmpty()) {
        removeNode(node->children.first());
    }

    // 从父节点或根节点移除
    if (node->parent) {
        QList<Node*>& siblings = node->parent->children;
        int idx = siblings.indexOf(node);
        if (idx >= 0) {
            beginRemoveRows(createIndex(0, 0, node->parent), idx, idx);
            siblings.removeAt(idx);
            endRemoveRows();
        }
    } else {
        int idx = m_nodes.indexOf(node);
        if (idx >= 0) {
            beginRemoveRows(QModelIndex(), idx, idx);
            m_nodes.removeAt(idx);
            endRemoveRows();
        }
    }

    m_idToNode.remove(node->identification);
    delete node;
    emitCountChanged();
}

void UniDeskComponentTreeModel::flattenNodes(QList<Node*> &out) const
{
    out.clear();
    // 深度优先遍历
    for (Node* node : m_nodes) {
        QList<Node*> stack;
        stack.append(node);
        while (!stack.isEmpty()) {
            Node* current = stack.takeLast();
            out.append(current);
            // 子节点逆序入栈，保证顺序正确
            for (int i = current->children.size() - 1; i >= 0; --i)
                stack.append(current->children[i]);
        }
    }
}

void UniDeskComponentTreeModel::emitCountChanged()
{
    _count = calcFlatCount();
    Q_EMIT countChanged();
}

QModelIndex UniDeskComponentTreeModel::findIndexById(const QString &identification) const
{
    Node* node = m_idToNode.value(identification, nullptr);
    if (!node)
        return QModelIndex();

    // 从根节点开始查找路径
    QList<Node*> path;
    Node* current = node;
    while (current) {
        path.prepend(current);
        current = current->parent;
    }

    QModelIndex index;
    for (int i = 0; i < path.size(); ++i) {
        Node* n = path[i];
        const QList<Node*>& siblings = n->parent ? n->parent->children : m_nodes;
        int row = siblings.indexOf(n);
        index = createIndex(row, 0, n);
    }
    return index;
}

void UniDeskComponentTreeModel::sortSiblings(Node* node)
{
    if (!node)
        return;
    QList<Node*>& siblings = node->parent ? node->parent->children : m_nodes;
    if (siblings.size() < 2)
        return;

    emit layoutAboutToBeChanged({}, QAbstractItemModel::VerticalSortHint);
    std::stable_sort(siblings.begin(), siblings.end(), [](Node* a, Node* b) {
        return a->z < b->z;
    });
    emit layoutChanged({}, QAbstractItemModel::VerticalSortHint);
}