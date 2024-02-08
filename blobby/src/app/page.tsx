import Image from "next/image";
import logo from "../../public/logo.png";
import HeroText from "./components/HeroText";
import Inputs from "./components/Inputs";

export default function Home() {
  return (
    <main className="flex flex-col items-center justify-between px-[16px] max-w-[390px} md:max-w-[834px} lg:max-w-[1728px}">
      <div className="pt-[80px] flex flex-col items-center">
        <Image src={logo} width={128} height={128} alt="logo" />
        <h3 className="pt-[32px] text-[#1A202C] text-[32px] text-center font-bold">
          Blobstream Starknet Demo
        </h3>
      </div>
      <HeroText />
      <Inputs />
    </main>
  );
}
