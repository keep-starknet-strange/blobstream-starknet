"use client";
import React, { ChangeEvent, useState } from "react";
import CopyToClipboardButton from "./CopyButton";

const BASE64_SVG_MIME = "data:image/svg+xml;base64,";

const Inputs = () => {
  const [svgText, setSvgText] = useState("");
  const [display, setDisplay] = useState("none");
  const [svgEncodedData, setSvgEncodedData] = useState("");

  const [svgDecodedData, setSvgDecodedData] = useState("");
  const [svgDecodingError, setSvgDecodingError] = useState("");

  const isBase64 = (s: string) => {
    const re = /^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$/;
    return re.test(s);
  };

  const buildSvgFromText = (userText: string) => {
    return `<svg xmlns="http://www.w3.org/2000/svg" width="128px" height="128px">
      <circle cx="64" cy="64" r="64" fill="#F37567" />
      <text
        x="64"
        y="64"
        font-size="16px"
        font-weight="700"
        font-family="sans-serif"
        text-anchor="middle"
        dy=".3em"
        fill="white">
        ${userText}
      </text>
    </svg>`;
  };

  const encodeSvg = (userText: string) => {
    const svg = buildSvgFromText(userText);
    const svgInBase64 = btoa(svg);
    setSvgEncodedData(`${BASE64_SVG_MIME}${svgInBase64}`);
  };

  const handleSVGTextChange = (e: ChangeEvent<HTMLInputElement>) => {
    const userText = e.target.value;

    if (userText.trim() !== "") {
      setDisplay("flex");
      setSvgText(userText);
      encodeSvg(userText);
    } else {
      setDisplay("none");
      setSvgText("");
      setSvgEncodedData("");
    }
  };

  const handleBase64SVGChange = (e: ChangeEvent<HTMLInputElement>) => {
    const eventData = e.target.value;

    if (eventData.length === 0) {
      setSvgDecodedData("");
      setSvgDecodingError("");
      return;
    }

    if (eventData.startsWith(BASE64_SVG_MIME)) {
      const base64Data = eventData.replace(BASE64_SVG_MIME, "");

      if (isBase64(base64Data)) {
        const decodedData = atob(base64Data);
        setSvgDecodedData(decodedData);
        setSvgDecodingError("");
      } else {
        setSvgDecodedData("");
        setSvgDecodingError(`Provided data are not base64 encoded`);
      }
    } else {
      setSvgDecodedData("");
      setSvgDecodingError(
        `Invalid MIME type: does not start with ${BASE64_SVG_MIME}`
      );
    }
  };

  return (
    <>
      <div className="flex gap-4 w-full justify-between my-4">
        <div className="flex flex-col gap-2 items-center">
          <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
            <span className="text-[#ffffff] text-center text-[16px]">1</span>
          </div>
          <div
            style={{ display }}
            className="w-[5px] bg-[#E2E8F0] h-full"></div>
        </div>
        <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-full">
          <h3 className="text-[#1A202C] text-[20px] font-bold">
            🎨 Start typing to generate your SVG
          </h3>
          <div className="flex flex-col">
            <label htmlFor="svg" className="text-[#6b7280] text-[16px] mt-4">
              Enter a text for your SVG
            </label>
            <input
              className="border border-[#e2e8f0] text-[16px] h-[40px] rounded-md"
              type="text"
              id="svg"
              name="svg"
              required
              onChange={handleSVGTextChange}
            />
            {svgText.length > 0 && (
              <div
                className="my-4 mx-auto"
                dangerouslySetInnerHTML={{ __html: buildSvgFromText(svgText) }}
              />
            )}
          </div>
        </div>
      </div>
      <div style={{ display }} className="flex-col w-full">
        <SetInputs
          num={2}
          title="💾 Save the SVG as a variable "
          description="In your terminal, set the SVG variable: "
          value={`export SVG="${svgEncodedData || ""}"`}
        />
        <SetInputs1
          num={3}
          title="✉️ Post the data to Celestia as plain text "
          description="First, set your auth token:"
          value={`export AUTH_TOKEN=$(celestia light auth admin --p2p.network mocha)`}
          description1="Next, post the SVG and save the output:"
          value1={`export OUTPUT=$(celestia blob submit 0x42690c204d39600fddd3 "$SVG" --token $AUTH_TOKEN)`}
        />
        <SetInputs
          num={4}
          title="🧊 Set the block height to retrieve your data "
          description="Then, set the block height: "
          value={`export HEIGHT=$(echo "$OUTPUT" | jq '.result.height') && echo "Height: $HEIGHT"`}
        />
        <SetInputs2
          num={5}
          title="✨ Retrieve the data from Celestia "
          description="Retrieve the shares by namespace and block height:"
          value={`celestia blob get-all $HEIGHT 0x42690c204d39600fddd3 --token $AUTH_TOKEN`}
          description1="Display only the data retrieved:"
          value1={`celestia blob get-all $HEIGHT 0x42690c204d39600fddd3 --token $AUTH_TOKEN | jq '.result[0].data'`}
          description2="Copy only the data retrieved, without quotes, to your clipboard:"
          value2={`celestia blob get-all $HEIGHT 0x42690c204d39600fddd3 --token $AUTH_TOKEN | jq -r '.result[0].data' | pbcopy`}
        />
        <div className="flex gap-4 w-full justify-between my-4">
          <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
            <span className="text-[#ffffff] text-center text-[16px]">6</span>
          </div>
          <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-full">
            <h3 className="text-[#1A202C] text-[20px] font-bold">
              🔗 Display the SVG you retrieved from Celestia
            </h3>
            <div className="flex flex-col">
              <label htmlFor="svg" className="text-[#6b7280] text-[16px] mt-4">
                Enter the parsed base64 SVG
              </label>
              <input
                className="border border-[#e2e8f0] text-[16px] rounded-md"
                type="text"
                id="svg"
                name="svg"
                required
                onChange={handleBase64SVGChange}
              />
              {svgDecodingError && (
                <div className="mt-1 text-xs text-red-500">
                  {svgDecodingError}
                </div>
              )}
              {svgDecodedData && (
                <div
                  className="my-4 mx-auto"
                  dangerouslySetInnerHTML={{ __html: svgDecodedData }}
                />
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

const SetInputs: React.FC<{
  num: number;
  title: string;
  description: string;
  value: string;
}> = ({ num, title, description, value }) => (
  <div className="flex gap-4 w-full justify-between my-4">
    <div className="flex flex-col gap-2 items-center">
      <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
        <span className="text-[#ffffff] text-center text-[16px]">{num}</span>
      </div>
      <div className="w-[5px] bg-[#E2E8F0] h-full"></div>
    </div>

    <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-full">
      <h3 className="text-[#1A202C] text-[20px] font-bold">{title}</h3>
      <div className="w-full mt-4">
        <div className="text-[#6b7280] text-[16px]">{description}</div>
        <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
          <span className="w-[218px] m-2 break-all">{value}</span>
          <CopyToClipboardButton text={value} />
        </div>
      </div>
    </div>
  </div>
);

const SetInputs1: React.FC<{
  num: number;
  title: string;
  description: string;
  value: string;
  description1: string;
  value1: string;
}> = ({ num, title, description, value, description1, value1 }) => (
  <div className="flex gap-4 w-full justify-between my-4">
    <div className="flex flex-col gap-2 items-center">
      <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
        <span className="text-[#ffffff] text-center text-[16px]">{num}</span>
      </div>
      <div className="w-[5px] bg-[#E2E8F0] h-full"></div>
    </div>
    <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-full">
      <h3 className="text-[#1A202C] text-[20px] font-bold">{title}</h3>
      <div>
        <div className="w-full mt-4">
          <div className="text-[#6b7280] text-[16px]">{description}</div>
          <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
            <span className="w-[218px] m-2">{value}</span>
            <CopyToClipboardButton text={value} />
          </div>
        </div>
        <div className="w-full mt-2">
          <div className="text-[#6b7280] text-[16px]">{description1}</div>
          <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
            <span className="w-[218px] m-2">{value1}</span>
            <CopyToClipboardButton text={value1} />
          </div>
        </div>
      </div>
    </div>
  </div>
);

const SetInputs2: React.FC<{
  num: number;
  title: string;
  description: string;
  value: string;
  description1: string;
  value1: string;
  description2: string;
  value2: string;
}> = ({
  num,
  title,
  description,
  value,
  description1,
  value1,
  description2,
  value2,
}) => (
  <div className="flex gap-4 w-full justify-between my-4">
    <div className="flex flex-col gap-2 items-center">
      <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
        <span className="text-[#ffffff] text-center text-[16px]">{num}</span>
      </div>
      <div className="w-[5px] bg-[#E2E8F0] h-full"></div>
    </div>
    <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-full">
      <div>
        <h3 className="text-[#1A202C] text-[20px] font-bold">{title}</h3>
        <div className="w-full mt-4">
          <div className="text-[#6b7280] text-[16px]">{description}</div>
          <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
            <span className="w-[218px] m-2">{value}</span>
            <CopyToClipboardButton text={value} />
          </div>
        </div>
        <div className="w-full mt-2">
          <div className="text-[#6b7280] text-[16px]">{description1}</div>
          <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
            <span className="w-[218px] m-2">{value1}</span>
            <CopyToClipboardButton text={value1} />
          </div>
        </div>
        <div className="w-full mt-2">
          <div className="text-[#6b7280] text-[16px]">{description2}</div>
          <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#e5e5e5] rounded-md">
            <span className="w-[218px] m-2">{value2}</span>
            <CopyToClipboardButton text={value2} />
          </div>
        </div>{" "}
      </div>
    </div>
  </div>
);

export default Inputs;
