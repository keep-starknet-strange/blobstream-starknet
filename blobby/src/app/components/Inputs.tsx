import Image from "next/image";
import React from "react";
import copy from "../../../public/copy.png";

const Inputs = () => {
  return (
    <>
      <div className="flex gap-4 w-full justify-between my-4">
        <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
          <span className="text-[#ffffff] text-center text-[16px]">1</span>
        </div>
        <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-[296px]">
          <h3 className="text-[#1A202C] text-[20px] font-bold">
            🎨 Start typing to generate your SVG
          </h3>
          <div className="flex flex-col">
            <label htmlFor="svg" className="text-[#6b7280] text-[16px]">
              Enter a text for your SVG
            </label>
            <input
              className="border border-[#e2e8f0] text-[16px] rounded-md"
              type="text"
              id="svg"
              name="svg"
              required
            />
          </div>
        </div>
      </div>
      <SetInputs
        num={2}
        title="💾 Save the SVG as a variable "
        description="In your terminal, set the SVG variable: "
        value={`export SVG="data:image/svg+xml;base64,CiAgICAgIDxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgICAgICAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNDAiIGZpbGw9IiNhZDExZjciIC8+CiAgICAgICAgPHRleHQgeD0iNTAiIHk9IjUwIiBmb250LXNpemU9IjEyIiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iIGZpbGw9IndoaXRlIj5GbG9yaWFuPC90ZXh0PgogICAgICA8L3N2Zz4KICAgIA=="`}
      />
      <SetInputs
        num={3}
        title="✉️ Post the data to Celestia as plain text "
        description="First, set your auth token:"
        value={`export AUTH_TOKEN=$(celestia light auth admin --p2p.network mocha)`}
      />
      <SetInputs
        num={4}
        title="🧊 Set the block height to retrieve your data "
        description="Then, set the block height: "
        value={`export HEIGHT=$(echo "$OUTPUT" | jq '.result.height') && echo "Height: $HEIGHT"`}
      />
      <SetInputs
        num={5}
        title="✨ Retrieve the data from Celestia "
        description="Retrieve the shares by namespace and block height:"
        value={`celestia blob get-all $HEIGHT 0x42690c204d39600fddd3 --token $AUTH_TOKEN`}
      />
      <SetInputs
        num={6}
        title="🔗 Display the SVG you retrieved from Celestia"
        description="Enter the parsed base64 SVG"
        value={`export SVG="data:image/svg+xml;base64,CiAgICAgIDxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgICAgICAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNDAiIGZpbGw9IiNhZDExZjciIC8+CiAgICAgICAgPHRleHQgeD0iNTAiIHk9IjUwIiBmb250LXNpemU9IjEyIiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iIGZpbGw9IndoaXRlIj5GbG9yaWFuPC90ZXh0PgogICAgICA8L3N2Zz4KICAgIA=="`}
      />
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
    <div className="bg-[#0d0d50] w-[48px] h-[48px] rounded-full flex justify-center items-center">
      <span className="text-[#ffffff] text-center text-[16px]">{num}</span>
    </div>
    <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] rounded-md w-[296px]">
      <h3 className="text-[#1A202C] text-[20px] font-bold">{title}</h3>
      <div className="w-full">
        <div className="text-[#6b7280] text-[16px]">{description}</div>
        <div className="w-full flex justify-between items-start border border-[#e2e8f0] text-[16px] text-[#000000] bg-[#6B7280] rounded-md">
          <span className="w-[218px] m-2">{value}</span>
          <Image
            className="m-2"
            src={copy}
            alt="copy"
            width={16}
            height={18.29}
          />
        </div>
      </div>
    </div>
  </div>
);

export default Inputs;
