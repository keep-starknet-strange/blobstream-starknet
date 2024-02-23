"use client";
import { useState } from "react";
import copy from "clipboard-copy";
import copied from "../../../public/copy.png";
import Image from "next/image";

const CopyToClipboardButton: React.FC<{ text: string }> = ({ text }) => {
  const [isCopied, setIsCopied] = useState(false);

  const handleCopyClick = async () => {
    try {
      await copy(text);
      setIsCopied(true);
    } catch (error) {
      console.error("Failed to copy text to clipboard", error);
    }
  };

  return (
    <div>
      <button className="text-[8px] text-gray-300" onClick={handleCopyClick}>
        {isCopied ? (
          "Copied!"
        ) : (
          <Image
            className="m-2"
            src={copied}
            alt="copy"
            width={16}
            height={18.29}
          />
        )}
      </button>
    </div>
  );
};

export default CopyToClipboardButton;
