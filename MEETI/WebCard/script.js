const PHOTO_ENDPOINT =
    "https://idyapfatxwaysidnjnzm.supabase.co/functions/v1/meeti-photo-url";

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
        // まずMBTI画像を表示する
        image.onload = () => {
            image.hidden = false;
        };

        image.onerror = () => {
            image.hidden = true;
        };

        image.hidden = true;
        image.alt = validType ? `${type}のイラスト` : "";

        if (validType) {
            image.src = `images/${type}.png`;
        } else {
            image.removeAttribute("src");
        }

        // 写真用トークンはURLの#以降から取得する
        const fragment = new URLSearchParams(
            window.location.hash.slice(1)
        );

        const photoToken = fragment.get("photoToken");

        if (photoToken && /^[0-9a-f]{64}$/.test(photoToken)) {
            void loadPersonalPhoto(image, photoToken);
        }
    }

    const interests = params.get("interests");
    const interestsElement = document.getElementById("interests");

    if (interestsElement && interests !== null) {
        interestsElement.replaceChildren();

        interests.split(",").forEach((interest) => {
            const text = interest.trim();
            if (!text) return;

            const span = document.createElement("span");
            span.textContent = text;
            interestsElement.appendChild(span);
        });
    }
}

async function loadPersonalPhoto(image, token) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);

    try {
        const response = await fetch(PHOTO_ENDPOINT, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ token }),
            cache: "no-store",
            credentials: "omit",
            referrerPolicy: "no-referrer",
            signal: controller.signal
        });

        if (!response.ok) return;

        const result = await response.json();

        // 写真なし・期限切れならMBTI画像を維持
        if (typeof result.photoUrl !== "string") return;

        const photoUrl = new URL(result.photoUrl);
        const endpointUrl = new URL(PHOTO_ENDPOINT);

        // 自分たちのSupabaseの署名付き画像URLだけを使う
        if (
            photoUrl.origin !== endpointUrl.origin ||
            !photoUrl.pathname.startsWith(
                "/storage/v1/object/sign/meeti-photos/"
            )
        ) {
            return;
        }

        // 写真を読み込めた場合だけ、表示を切り替える
        const photo = new Image();
        photo.referrerPolicy = "no-referrer";

        photo.onload = () => {
            image.referrerPolicy = "no-referrer";
            image.alt = "本人のプロフィール写真";
            image.src = photo.src;
            image.hidden = false;
        };

        photo.src = photoUrl.href;
    } catch {
        // 通信失敗時もMBTI画像を維持する
    } finally {
        clearTimeout(timeout);
    }
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", updateCard);
} else {
    updateCard();
}
