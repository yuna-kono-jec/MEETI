function updateCard() {
    const params = new URLSearchParams(window.location.search);

    const name = params.get("name");
    const mbti = params.get("mbti");
    const number = params.get("number");
    const interests = params.get("interests");
    const message = params.get("message");

    function setText(id, value) {
        const element = document.getElementById(id);

        if (element && value !== null) {
            element.textContent = value;
        }
    }

    setText("name", name);
    setText("message", message);

    if (number !== null) {
        setText("number", `No.${number.padStart(3, "0")}`);
    }

    if (mbti !== null) {
        const type = mbti.trim().toUpperCase();

        setText(
            "mbti",
            type === "INFP" ? "INFP / 仲介者タイプ" : type
        );

        const image = document.getElementById("profile-image");

        if (image) {
            // 固定の人物写真を表示しない
            image.removeAttribute("src");
            image.hidden = true;

            if (type === "INFP") {
                image.onload = function () {
                    image.hidden = false;
                };

                image.onerror = function () {
                    image.hidden = true;
                };

                image.alt = "INFPのイラスト";
                image.src = "images/INFP.png";
            }
        }
    }

    const interestsElement = document.getElementById("interests");

    if (interestsElement && interests !== null) {
        interestsElement.replaceChildren();

        interests.split(",").forEach(function (interest) {
            const text = interest.trim();
            if (!text) return;

            const span = document.createElement("span");
            span.textContent = text;
            interestsElement.appendChild(span);
        });
    }
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", updateCard);
} else {
    updateCard();
}
function updateCard() {
    const params = new URLSearchParams(window.location.search);

    const typeNames = {
        ISTJ: "管理者",
        ISFJ: "擁護者",
        INFJ: "提唱者",
        INTJ: "建築家",
        ISTP: "巨匠",
        ISFP: "冒険家",
        INFP: "仲介者",
        INTP: "論理学者",
        ESTP: "起業家",
        ESFP: "エンターテイナー",
        ENFP: "運動家",
        ENTP: "討論者",
        ESTJ: "幹部",
        ESFJ: "領事",
        ENFJ: "主人公",
        ENTJ: "指揮官"
    };

    function setText(id, value) {
        const element = document.getElementById(id);

        if (element && value !== null) {
            element.textContent = value;
        }
    }

    setText("name", params.get("name"));
    setText("message", params.get("message"));

    const number = params.get("number");

    if (number !== null) {
        setText("number", `No.${number.padStart(3, "0")}`);
    }

    // URLにMBTIがない場合は、確認用にINFPを表示
    const type = (params.get("mbti") ?? "INFP")
        .trim()
        .toUpperCase();

    const validType = Object.prototype.hasOwnProperty.call(
        typeNames,
        type
    );

    setText(
        "mbti",
        validType ? `${type} / ${typeNames[type]}タイプ` : type
    );

    const image = document.getElementById("profile-image");

    if (image) {
        image.hidden = true;
        image.removeAttribute("src");

        if (validType) {
            image.onload = function () {
                image.hidden = false;
            };

            image.onerror = function () {
                image.hidden = true;
            };

            image.alt = `${type}のイラスト`;
            image.src = `images/${type}.png`;
        }
    }

    const interests = params.get("interests");
    const interestsElement = document.getElementById("interests");

    if (interestsElement && interests !== null) {
        interestsElement.replaceChildren();

        interests.split(",").forEach(function (interest) {
            const text = interest.trim();
            if (!text) return;

            const span = document.createElement("span");
            span.textContent = text;
            interestsElement.appendChild(span);
        });
    }
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", updateCard);
} else {
    updateCard();
}
