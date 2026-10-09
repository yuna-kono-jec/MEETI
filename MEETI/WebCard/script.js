function updateCard() {
    //  URLから情報を取得する
    const params = new URLSearchParams(window.location.search);

    // 名前を取得
    const name = params.get("name");

    // MBTIを取得
    const mbti = params.get("mbti");

    // No.を取得
    const number = params.get("number");

    // 趣味を取得
    const interests = params.get("interests");

    // メッセージを取得
    const message = params.get("message");
    
    function setText(id, value) {
        const element = document.getElementById(id);
        
        if (element && value !== null) {
            element.textContent = value;
        }
    }
    
    setText("name", name);
    setText("mbti", mbti);
    setText("message", message);
    
    if (number !== null) {
        setText("number", `No.${number.padStart(3, "0")}`);
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
    document.addEventlistener("DOMContentLoaded", updateCard);
} else {
    updateCard();
}



//// HTMLの名前を書き換える
//if (participantName) {
//    document.getElementById("name").textContent = participantName;
//}
//
//// HTMLのMBTIを書き換える
//if (mbti) {
//    document.getElementById("mbti").textContent = mbti;
//}
//
//// HTMLの趣味を書き換える
//if (interests) {
//
//    const interestsList = interests.split(",");
//
//    const interestsElement = document.getElementById("interests");
//
//    interestsElement.innerHTML = "";
//
//    interestsList.forEach(function(interests) {
//
//        const span = document.createElement("span");
//
//        span.textContent = interests;
//
//        interestsElement.appendChild(span);
//
//    });
//
//}

