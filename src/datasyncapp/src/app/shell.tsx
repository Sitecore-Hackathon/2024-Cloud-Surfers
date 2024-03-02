'use client';
import { Logo } from '@/components/atoms/Logo';
import {
  Box,
  Drawer,
  DrawerContent,
  DrawerOverlay,
  Flex,
  Icon,
  Text,
  useColorModeValue,
  useDisclosure,
} from '@chakra-ui/react';
import { mdiHomeVariantOutline } from '@mdi/js';
import { iconSitecore } from '@sitecore/blok-theme';
import React from 'react';

type ShellProps = {
  children: React.ReactNode;
};
export const Shell = ({ children }: ShellProps) => {
  const sidebar = useDisclosure();
  const integrations = useDisclosure();
  const color = useColorModeValue('gray.600', 'gray.300');

  const NavItem = (props) => {
    const { icon, children, ...rest } = props;
    return (
      <Flex
        align="center"
        px="4"
        pl="4"
        py="3"
        cursor="pointer"
        color="inherit"
        _dark={{
          color: 'gray.400',
        }}
        _hover={{
          bg: 'gray.100',
          _dark: {
            bg: 'gray.900',
          },
          color: 'gray.900',
        }}
        role="group"
        fontWeight="semibold"
        transition=".15s ease"
        {...rest}
      >
        {icon && (
          <Icon
            mx="2"
            boxSize="5"
            _groupHover={{
              color: color,
            }}
            as={icon}
          >
            <path d={icon} />
          </Icon>
        )}
        {children}
      </Flex>
    );
  };

  const SidebarContent = (props) => (
    <Box
      as="nav"
      pos="fixed"
      top="0"
      left="0"
      zIndex="sticky"
      h="full"
      pb="10"
      overflowX="hidden"
      overflowY="auto"
      bg="white"
      _dark={{
        bg: 'gray.800',
      }}
      border
      color="inherit"
      borderRightWidth="1px"
      w="60"
      {...props}
    >
      <Flex px="4" py="5" align="center">
        <a href="#">
          <Logo />
        </a>
      </Flex>
      <Flex direction="column" as="nav" fontSize="sm" color="gray.600" aria-label="Main Navigation">
        <NavItem icon={mdiHomeVariantOutline}>
          <a href="#">Home</a>
        </NavItem>
        <NavItem icon={iconSitecore}>
          <a href="https://portal.sitecorecloud.io/">SitecoreCloud Portal</a>
        </NavItem>
        {/* <NavItem icon={FaRss}>Articles</NavItem> */}
        {/* <NavItem icon={HiCollection}>Collections</NavItem>
          <NavItem icon={FaClipboardCheck}>Checklists</NavItem>         
          <NavItem icon={AiFillGift}>Changelog</NavItem>
          <NavItem icon={BsGearFill}>Settings</NavItem> */}
      </Flex>
    </Box>
  );

  return (
    <Box
      as="section"
      bg="gray.50"
      _dark={{
        bg: 'gray.700',
      }}
      minH="100vh"
    >
      <SidebarContent
        display={{
          base: 'none',
          md: 'unset',
        }}
      />
      <Drawer isOpen={sidebar.isOpen} onClose={sidebar.onClose} placement="left">
        <DrawerOverlay />
        <DrawerContent>
          <SidebarContent w="full" borderRight="none" />
        </DrawerContent>
      </Drawer>
      <Box
        ml={{
          base: 0,
          md: 60,
        }}
        transition=".3s ease"
      >
        <Flex
          as="header"
          align="center"
          justify="space-between"
          w="full"
          px="4"
          bg="white"
          _dark={{
            bg: 'gray.800',
          }}
          borderBottomWidth="1px"
          color="inherit"
          h="14"
        >
          {/* <IconButton
              aria-label="Menu"
              display={{
                base: "inline-flex",
                md: "none",
              }}
              onClick={sidebar.onOpen}
              icon={}
              size="sm"
            />
            <InputGroup
              w="96"
              display={{
                base: "none",
                md: "flex",
              }}
            >
              <InputLeftElement color="gray.500">
                <FiSearch />
              </InputLeftElement>
              <Input placeholder="Search for articles..." />
            </InputGroup> */}

          <Flex align="center">
            <Text
              fontSize="2xl"
              ml="2"
              color="brand.500"
              _dark={{
                color: 'white',
              }}
              fontWeight="semibold"
            >
              XM Cloud Operator Hub
            </Text>
            {/* <Icon color="gray.500" as={FaBell} cursor="pointer" /> */}
            {/* <Avatar
                ml="4"
                size="sm"
                name="anubra266"
                src="https://avatars.githubusercontent.com/u/30869823?v=4"
                cursor="pointer"
              /> */}
          </Flex>
        </Flex>

        <Box as="main" p="4">
          {children}
        </Box>
      </Box>
    </Box>
  );
};
