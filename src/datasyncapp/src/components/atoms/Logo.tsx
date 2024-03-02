import Image from 'next/image';

export const Logo = () => {
  return (
    <Image priority={true} width={200} height={300} alt="Cloud Surfers logo" src={'/logo-h.png'} />
  );
};
