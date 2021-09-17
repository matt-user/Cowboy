import React, { Component } from 'react';
import { Button } from 'semantic-ui-react';
import Link from 'next/link';
import battleHandler from '../ethereum/battleHandler';
import Layout from '../components/Layout';

class BattleIndex extends Component {
    render() {
        return (
            <Layout>
                <h1>Battles</h1>
                <Link href="/battles/new">
                    <a><Button floated="right" content="Create a Battle" icon="add circle" primary /></a>
                </Link>
            </Layout>
        );
    }
}

export default BattleIndex;