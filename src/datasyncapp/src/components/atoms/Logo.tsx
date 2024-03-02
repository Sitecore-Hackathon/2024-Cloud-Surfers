import Image from 'next/image'

export const Logo = () => {
  return <Image width={144} height={200} alt='Cloud Surfers logo' src={'/logo-v.png'}/>
}