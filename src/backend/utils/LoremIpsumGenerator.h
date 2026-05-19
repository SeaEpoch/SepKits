#pragma once
#include <QObject>
#include <QString>

class LoremIpsumGenerator : public QObject {
    Q_OBJECT

public:
    explicit LoremIpsumGenerator(QObject *parent = nullptr);

    Q_INVOKABLE QString generate(int count, int unitIndex, int langIndex) const;

private:
    static QString generateEnWords(int count);
    static QString generateEnSentences(int count);
    static QString generateEnParagraphs(int count);
    static QString generateZhWords(int count);
    static QString generateZhSentences(int count);
    static QString generateZhParagraphs(int count);
    static int randInt(int min, int max);
};
