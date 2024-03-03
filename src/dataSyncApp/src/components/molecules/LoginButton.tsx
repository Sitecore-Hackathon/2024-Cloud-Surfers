'use client';
import { Button } from '@chakra-ui/react';
import { signIn, signOut, useSession } from 'next-auth/react';
import Gravatar from 'react-gravatar';

type UserLoginProps = {
  rating?: Gravatar.Rating;
  defaultImage?: Gravatar.DefaultImage;
  profileUrl?: string;
};

const UserLogin = (props: UserLoginProps): JSX.Element => {
  const { data: session } = useSession();

  if (session?.user) {
    return (
      <>
        {/* <Link href={props.profileUrl || '/user/profile'}>
          <Gravatar
            email={session?.user?.email as string}
            size={48}
            rating={props.rating || 'g'}
            default={props.defaultImage || 'mp'}
          />
          Profile
        </Link> */}
        <Button
          variant="outline"
          // href={`/api/auth/signout`}
          onClick={(e) => {
            e.preventDefault();
            signOut();
          }}
        >
          Sign Out
        </Button>
      </>
    );
  } else {
    return (
      <Button
        variant="primary"
        // href={`/api/auth/signin/azure-ad`}
        onClick={(e) => {
          e.preventDefault();
          signIn('azure-ad');
        }}
      >
        Sign In
      </Button>
    );
  }
};

export default UserLogin;
