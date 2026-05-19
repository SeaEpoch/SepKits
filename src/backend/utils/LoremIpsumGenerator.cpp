#include "LoremIpsumGenerator.h"
#include <QRandomGenerator>
#include <QStringList>

// ─── Data pools ─────────────────────────────────────────────────────

static const QStringList enWords = {
    QStringLiteral("lorem"), QStringLiteral("ipsum"), QStringLiteral("dolor"),
    QStringLiteral("sit"), QStringLiteral("amet"), QStringLiteral("consectetur"),
    QStringLiteral("adipiscing"), QStringLiteral("elit"), QStringLiteral("sed"),
    QStringLiteral("do"), QStringLiteral("eiusmod"), QStringLiteral("tempor"),
    QStringLiteral("incididunt"), QStringLiteral("ut"), QStringLiteral("labore"),
    QStringLiteral("et"), QStringLiteral("dolore"), QStringLiteral("magna"),
    QStringLiteral("aliqua"), QStringLiteral("enim"), QStringLiteral("ad"),
    QStringLiteral("minim"), QStringLiteral("veniam"), QStringLiteral("quis"),
    QStringLiteral("nostrud"), QStringLiteral("exercitation"), QStringLiteral("ullamco"),
    QStringLiteral("laboris"), QStringLiteral("nisi"), QStringLiteral("aliquip"),
    QStringLiteral("ex"), QStringLiteral("ea"), QStringLiteral("commodo"),
    QStringLiteral("consequat"), QStringLiteral("duis"), QStringLiteral("aute"),
    QStringLiteral("irure"), QStringLiteral("dolor"), QStringLiteral("in"),
    QStringLiteral("reprehenderit"), QStringLiteral("voluptate"), QStringLiteral("velit"),
    QStringLiteral("esse"), QStringLiteral("cillum"), QStringLiteral("fugiat"),
    QStringLiteral("nulla"), QStringLiteral("pariatur"), QStringLiteral("excepteur"),
    QStringLiteral("sint"), QStringLiteral("occaecat"), QStringLiteral("cupidatat"),
    QStringLiteral("non"), QStringLiteral("proident"), QStringLiteral("sunt"),
    QStringLiteral("culpa"), QStringLiteral("qui"), QStringLiteral("officia"),
    QStringLiteral("deserunt"), QStringLiteral("mollit"), QStringLiteral("anim"),
    QStringLiteral("id"), QStringLiteral("est"), QStringLiteral("laborum")
};

static const QString zhCharacters = QStringLiteral(
    "天地玄黄宇宙洪荒日月盈昃辰宿列张寒来暑往秋收冬藏"
    "闰余成岁律吕调阳云腾致雨露结为霜金生丽水玉出昆冈"
    "剑号巨阙珠称夜光果珍李柰菜重芥姜海咸河淡鳞潜羽翔"
    "龙师火帝鸟官人皇始制文字乃服衣裳推位让国有虞陶唐"
    "吊民伐罪周发殷汤坐朝问道垂拱平章爱育黎首臣伏戎羌"
    "遐迩一体率宾归王鸣凤在竹白驹食场化被草木赖及万方"
    "盖此身发四大五常恭惟鞠养岂敢毁伤女慕贞洁男效才良"
    "知过必改得能莫忘罔谈彼短靡恃己长信使可覆器欲难量"
    "墨悲丝染诗赞羔羊景行维贤克念作圣德建名立形端表正"
    "空谷传声虚堂习听祸因恶积福缘善庆尺璧非宝寸阴是竞"
    "资父事君曰严与敬孝当竭力忠则尽命临深履薄夙兴温凊"
    "似兰斯馨如松之盛川流不息渊澄取映容止若思言辞安定"
    "笃初诚美慎终宜令荣业所基籍甚无竟学优登仕摄职从政"
    "存以甘棠去而益咏乐殊贵贱礼别尊卑上和下睦夫唱妇随"
    "外受傅训入奉母仪诸姑伯叔犹子比儿孔怀兄弟同气连枝"
    "交友投分切磨箴规仁慈隐恻造次弗离节义廉退颠沛匪亏"
    "性静情逸心动神疲守真志满逐物意移坚持雅操好爵自縻"
);

// ─── Helpers ────────────────────────────────────────────────────────

int LoremIpsumGenerator::randInt(int min, int max)
{
    return QRandomGenerator::global()->bounded(min, max + 1);
}

// ─── Constructor ────────────────────────────────────────────────────

LoremIpsumGenerator::LoremIpsumGenerator(QObject *parent)
    : QObject(parent)
{
}

// ─── English generation ─────────────────────────────────────────────

QString LoremIpsumGenerator::generateEnWords(int count)
{
    QStringList words;
    words.reserve(count);
    for (int i = 0; i < count; ++i)
        words.append(enWords.at(randInt(0, enWords.size() - 1)));
    if (!words.isEmpty())
        words[0] = words[0].at(0).toUpper() + words[0].mid(1);
    return words.join(QStringLiteral(" ")) + QStringLiteral(".");
}

QString LoremIpsumGenerator::generateEnSentences(int count)
{
    static const QStringList puncts = {
        QStringLiteral(","), QStringLiteral("."), QStringLiteral("?"),
        QStringLiteral("!"), QStringLiteral(";")
    };
    static const QStringList endPuncts = {
        QStringLiteral("."), QStringLiteral("!"), QStringLiteral("?")
    };

    QStringList sentences;
    sentences.reserve(count);
    for (int i = 0; i < count; ++i) {
        QString s = generateEnWords(randInt(6, 18));
        s.chop(1); // remove default "."
        if (i < count - 1)
            s += puncts.at(randInt(0, puncts.size() - 1));
        else
            s += endPuncts.at(randInt(0, endPuncts.size() - 1));
        sentences.append(s);
    }
    return sentences.join(QStringLiteral(" "));
}

QString LoremIpsumGenerator::generateEnParagraphs(int count)
{
    static const QStringList puncts = {
        QStringLiteral(","), QStringLiteral("."), QStringLiteral("?"),
        QStringLiteral("!"), QStringLiteral(";")
    };
    static const QStringList endPuncts = {
        QStringLiteral("."), QStringLiteral("!"), QStringLiteral("?")
    };

    QStringList paragraphs;
    paragraphs.reserve(count);
    for (int i = 0; i < count; ++i) {
        int sc = randInt(3, 5);
        QStringList lines;
        lines.reserve(sc);
        for (int j = 0; j < sc; ++j) {
            QString s = generateEnWords(randInt(6, 18));
            s.chop(1);
            if (j < sc - 1)
                s += puncts.at(randInt(0, puncts.size() - 1));
            else
                s += endPuncts.at(randInt(0, endPuncts.size() - 1));
            lines.append(s);
        }
        paragraphs.append(lines.join(QStringLiteral(" ")));
    }
    return paragraphs.join(QStringLiteral("\n\n"));
}

// ─── Chinese generation ─────────────────────────────────────────────

QString LoremIpsumGenerator::generateZhWords(int count)
{
    QString result;
    result.reserve(count);
    for (int i = 0; i < count; ++i)
        result += zhCharacters.at(randInt(0, zhCharacters.size() - 1));
    return result;
}

QString LoremIpsumGenerator::generateZhSentences(int count)
{
    static const QStringList midPuncts = {
        QStringLiteral("，"),   // ，
        QStringLiteral("。"),   // 。
        QStringLiteral("！"),   // ！
        QStringLiteral("？"),   // ？
        QStringLiteral("；")    // ；
    };
    static const QStringList endPuncts = {
        QStringLiteral("。"),   // 。
        QStringLiteral("！"),   // ！
        QStringLiteral("？")    // ？
    };

    QStringList sentences;
    sentences.reserve(count);
    for (int i = 0; i < count; ++i) {
        int len = randInt(10, 30);
        QString s;
        s.reserve(len * 2);
        for (int j = 0; j < len; ++j) {
            s += zhCharacters.at(randInt(0, zhCharacters.size() - 1));
            if (j < len - 1 && QRandomGenerator::global()->generateDouble() < 0.2)
                s += midPuncts.at(randInt(0, midPuncts.size() - 1));
        }
        s += endPuncts.at(randInt(0, endPuncts.size() - 1));
        sentences.append(s);
    }
    return sentences.join(QString());
}

QString LoremIpsumGenerator::generateZhParagraphs(int count)
{
    static const QStringList midPuncts = {
        QStringLiteral("，"),   // ，
        QStringLiteral("。"),   // 。
        QStringLiteral("！"),   // ！
        QStringLiteral("？"),   // ？
        QStringLiteral("；")    // ；
    };
    static const QStringList endPuncts = {
        QStringLiteral("。"),   // 。
        QStringLiteral("！"),   // ！
        QStringLiteral("？")    // ？
    };

    QStringList paragraphs;
    paragraphs.reserve(count);
    for (int i = 0; i < count; ++i) {
        int sc = randInt(5, 10);
        QStringList lines;
        lines.reserve(sc);
        for (int j = 0; j < sc; ++j) {
            int len = randInt(10, 30);
            QString s;
            s.reserve(len * 2);
            for (int k = 0; k < len; ++k) {
                s += zhCharacters.at(randInt(0, zhCharacters.size() - 1));
                if (k < len - 1 && QRandomGenerator::global()->generateDouble() < 0.2)
                    s += midPuncts.at(randInt(0, midPuncts.size() - 1));
            }
            s += endPuncts.at(randInt(0, endPuncts.size() - 1));
            lines.append(s);
        }
        paragraphs.append(lines.join(QString()));
    }
    return paragraphs.join(QStringLiteral("\n\n"));
}

// ─── Public dispatcher ──────────────────────────────────────────────

QString LoremIpsumGenerator::generate(int count, int unitIndex, int langIndex) const
{
    if (count < 1) return {};
    if (count > 999) count = 999;

    if (langIndex == 1) {
        switch (unitIndex) {
            case 0: return generateZhWords(count);
            case 1: return generateZhSentences(count);
            case 2: return generateZhParagraphs(count);
            default: return {};
        }
    } else {
        switch (unitIndex) {
            case 0: return generateEnWords(count);
            case 1: return generateEnSentences(count);
            case 2: return generateEnParagraphs(count);
            default: return {};
        }
    }
}
