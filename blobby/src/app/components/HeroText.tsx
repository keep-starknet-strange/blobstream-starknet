import React from "react";

const HeroText = () => {
  return (
    <div className="bg-[#ffffff] p-4 border border-[#e2e8f0] m-4 rounded-md w-full">
      <div className="text-[#6b7280] text-[16px]">
        This demo will show you{" "}
        <span className="font-bold">how Starknet L3s can use Celestia</span> as
        a Data Availability layer. Blobstream allows Celestia block header data
        roots to be relayed from Celestia to Starknet. The only pre-requisite
        for this tutorial is to 
        <a
          href="https://docs.celestia.org/developers/node-tutorial"
          target="_blank"
        >
          run a Celestia light node
        </a>
         that is funded with testnet tokens. It is also recommended to read
        about the 
        <a
          href="https://docs.celestia.org/developers/node-tutorial"
          target="_blank"
        >
          RPC API and the Celestia Node CLI guide.
        </a>
      </div>
    </div>
  );
};

export default HeroText;
