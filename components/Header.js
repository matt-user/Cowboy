import React from 'react';
import { Menu } from 'semantic-ui-react';
import Link from 'next/link';

const Header = () => {
    return (
        <Menu style={{ marginTop: '10px' }}>
            <Link href='/'>
                <a className="item">Home</a>
            </Link>

            <Menu.Menu position="right">
                <Link href="/battles/new">
                    <a className="item">+</a>
                </Link>
            </Menu.Menu>
        </Menu>
    );
};
export default Header;