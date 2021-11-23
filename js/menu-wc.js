'use strict';

customElements.define('compodoc-menu', class extends HTMLElement {
    constructor() {
        super();
        this.isNormalMode = this.getAttribute('mode') === 'normal';
    }

    connectedCallback() {
        this.render(this.isNormalMode);
    }

    render(isNormalMode) {
        let tp = lithtml.html(`
        <nav>
            <ul class="list">
                <li class="title">
                    <a href="index.html" data-type="index-link">lethean-app documentation</a>
                </li>

                <li class="divider"></li>
                ${ isNormalMode ? `<div id="book-search-input" role="search"><input type="text" placeholder="Type to search"></div>` : '' }
                <li class="chapter">
                    <a data-type="chapter-link" href="index.html"><span class="icon ion-ios-home"></span>Getting started</a>
                    <ul class="links">
                        <li class="link">
                            <a href="overview.html" data-type="chapter-link">
                                <span class="icon ion-ios-keypad"></span>Overview
                            </a>
                        </li>
                        <li class="link">
                            <a href="index.html" data-type="chapter-link">
                                <span class="icon ion-ios-paper"></span>README
                            </a>
                        </li>
                                <li class="link">
                                    <a href="dependencies.html" data-type="chapter-link">
                                        <span class="icon ion-ios-list"></span>Dependencies
                                    </a>
                                </li>
                    </ul>
                </li>
                    <li class="chapter modules">
                        <a data-type="chapter-link" href="modules.html">
                            <div class="menu-toggler linked" data-toggle="collapse" ${ isNormalMode ?
                                'data-target="#modules-links"' : 'data-target="#xs-modules-links"' }>
                                <span class="icon ion-ios-archive"></span>
                                <span class="link-name">Modules</span>
                                <span class="icon ion-ios-arrow-down"></span>
                            </div>
                        </a>
                        <ul class="links collapse " ${ isNormalMode ? 'id="modules-links"' : 'id="xs-modules-links"' }>
                            <li class="link">
                                <a href="modules/AppModule.html" data-type="entity-link" >AppModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-AppModule-bf9cbea5fc19138d3101c74ab3f422740329f6598f4fd6da9a45ce381e11027914a5aa89ecfa4817b6423a8bedfd3f4d07a43cecd4b75c4ae540b9488d34d4da"' : 'data-target="#xs-components-links-module-AppModule-bf9cbea5fc19138d3101c74ab3f422740329f6598f4fd6da9a45ce381e11027914a5aa89ecfa4817b6423a8bedfd3f4d07a43cecd4b75c4ae540b9488d34d4da"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-AppModule-bf9cbea5fc19138d3101c74ab3f422740329f6598f4fd6da9a45ce381e11027914a5aa89ecfa4817b6423a8bedfd3f4d07a43cecd4b75c4ae540b9488d34d4da"' :
                                            'id="xs-components-links-module-AppModule-bf9cbea5fc19138d3101c74ab3f422740329f6598f4fd6da9a45ce381e11027914a5aa89ecfa4817b6423a8bedfd3f4d07a43cecd4b75c4ae540b9488d34d4da"' }>
                                            <li class="link">
                                                <a href="components/AppComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >AppComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/AppRoutingModule.html" data-type="entity-link" >AppRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/AuthModule.html" data-type="entity-link" >AuthModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-AuthModule-7e0d022fcc6502dcbd1827c0b2180efbfbee32856f95581087092957a130dcc63d65e4b02a15d3659563f7fefab6cfe18756b911bb5b054b041dec1407518c56"' : 'data-target="#xs-components-links-module-AuthModule-7e0d022fcc6502dcbd1827c0b2180efbfbee32856f95581087092957a130dcc63d65e4b02a15d3659563f7fefab6cfe18756b911bb5b054b041dec1407518c56"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-AuthModule-7e0d022fcc6502dcbd1827c0b2180efbfbee32856f95581087092957a130dcc63d65e4b02a15d3659563f7fefab6cfe18756b911bb5b054b041dec1407518c56"' :
                                            'id="xs-components-links-module-AuthModule-7e0d022fcc6502dcbd1827c0b2180efbfbee32856f95581087092957a130dcc63d65e4b02a15d3659563f7fefab6cfe18756b911bb5b054b041dec1407518c56"' }>
                                            <li class="link">
                                                <a href="components/LoginComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >LoginComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/BlockchainModule.html" data-type="entity-link" >BlockchainModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-BlockchainModule-c05fd2bf0e7f425adf87847f5257254db49d5c75e6d3e45710c0929e3ff048ad38d9af09e0bb52b73928b19bf38003b1cd3b2da65ec81e7410a68d225694abd1"' : 'data-target="#xs-components-links-module-BlockchainModule-c05fd2bf0e7f425adf87847f5257254db49d5c75e6d3e45710c0929e3ff048ad38d9af09e0bb52b73928b19bf38003b1cd3b2da65ec81e7410a68d225694abd1"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-BlockchainModule-c05fd2bf0e7f425adf87847f5257254db49d5c75e6d3e45710c0929e3ff048ad38d9af09e0bb52b73928b19bf38003b1cd3b2da65ec81e7410a68d225694abd1"' :
                                            'id="xs-components-links-module-BlockchainModule-c05fd2bf0e7f425adf87847f5257254db49d5c75e6d3e45710c0929e3ff048ad38d9af09e0bb52b73928b19bf38003b1cd3b2da65ec81e7410a68d225694abd1"' }>
                                            <li class="link">
                                                <a href="components/BlockchainComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >BlockchainComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/BlockchainRoutingModule.html" data-type="entity-link" >BlockchainRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/ChartModule.html" data-type="entity-link" >ChartModule</a>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                        'data-target="#directives-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' : 'data-target="#xs-directives-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' }>
                                        <span class="icon ion-md-code-working"></span>
                                        <span>Directives</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="directives-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' :
                                        'id="xs-directives-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' }>
                                        <li class="link">
                                            <a href="directives/ChartDirective.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >ChartDirective</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="chapter inner">
                                    <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                        'data-target="#injectables-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' : 'data-target="#xs-injectables-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' }>
                                        <span class="icon ion-md-arrow-round-down"></span>
                                        <span>Injectables</span>
                                        <span class="icon ion-ios-arrow-down"></span>
                                    </div>
                                    <ul class="links collapse" ${ isNormalMode ? 'id="injectables-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' :
                                        'id="xs-injectables-links-module-ChartModule-e2316919c4ee6b733704b74a34a6d2332942ed59435c7319c15bb2262dc02004f0bf1abfaf2a4106969aabc7e334e59036c64575bde627254cea1e7247288d8e"' }>
                                        <li class="link">
                                            <a href="injectables/ChartService.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >ChartService</a>
                                        </li>
                                    </ul>
                                </li>
                            </li>
                            <li class="link">
                                <a href="modules/ConsoleModule.html" data-type="entity-link" >ConsoleModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-ConsoleModule-658b63cc741f6b1390b844af9f80b75266e0de5544a9595e003010f76ae24b528706a9789b7f3dcc5df9decf2cf946415eebb600083f03fb73a342580976ace9"' : 'data-target="#xs-components-links-module-ConsoleModule-658b63cc741f6b1390b844af9f80b75266e0de5544a9595e003010f76ae24b528706a9789b7f3dcc5df9decf2cf946415eebb600083f03fb73a342580976ace9"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-ConsoleModule-658b63cc741f6b1390b844af9f80b75266e0de5544a9595e003010f76ae24b528706a9789b7f3dcc5df9decf2cf946415eebb600083f03fb73a342580976ace9"' :
                                            'id="xs-components-links-module-ConsoleModule-658b63cc741f6b1390b844af9f80b75266e0de5544a9595e003010f76ae24b528706a9789b7f3dcc5df9decf2cf946415eebb600083f03fb73a342580976ace9"' }>
                                            <li class="link">
                                                <a href="components/ConsoleComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >ConsoleComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/ConsoleRoutingModule.html" data-type="entity-link" >ConsoleRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/DataModule.html" data-type="entity-link" >DataModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/LogsModule.html" data-type="entity-link" >LogsModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-LogsModule-5d21f88d60d3eb636b7293877c7a010a550d251c988c72adb32ab9e2aca446ab49b3d24c0d83bc5b68f701a6c6bd23cf0e78fd1f8c7cfd395e67eda2b07428d6"' : 'data-target="#xs-components-links-module-LogsModule-5d21f88d60d3eb636b7293877c7a010a550d251c988c72adb32ab9e2aca446ab49b3d24c0d83bc5b68f701a6c6bd23cf0e78fd1f8c7cfd395e67eda2b07428d6"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-LogsModule-5d21f88d60d3eb636b7293877c7a010a550d251c988c72adb32ab9e2aca446ab49b3d24c0d83bc5b68f701a6c6bd23cf0e78fd1f8c7cfd395e67eda2b07428d6"' :
                                            'id="xs-components-links-module-LogsModule-5d21f88d60d3eb636b7293877c7a010a550d251c988c72adb32ab9e2aca446ab49b3d24c0d83bc5b68f701a6c6bd23cf0e78fd1f8c7cfd395e67eda2b07428d6"' }>
                                            <li class="link">
                                                <a href="components/LogsComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >LogsComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/PipesModule.html" data-type="entity-link" >PipesModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#pipes-links-module-PipesModule-eca1947a52fbf67ecd12f87e4da342179bb8d68313782ba41b1269cf0bd7bd96cfb31ab794dce024efd6eeb580696abbf9111adddc65f8ab7945ff214e726f19"' : 'data-target="#xs-pipes-links-module-PipesModule-eca1947a52fbf67ecd12f87e4da342179bb8d68313782ba41b1269cf0bd7bd96cfb31ab794dce024efd6eeb580696abbf9111adddc65f8ab7945ff214e726f19"' }>
                                            <span class="icon ion-md-add"></span>
                                            <span>Pipes</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="pipes-links-module-PipesModule-eca1947a52fbf67ecd12f87e4da342179bb8d68313782ba41b1269cf0bd7bd96cfb31ab794dce024efd6eeb580696abbf9111adddc65f8ab7945ff214e726f19"' :
                                            'id="xs-pipes-links-module-PipesModule-eca1947a52fbf67ecd12f87e4da342179bb8d68313782ba41b1269cf0bd7bd96cfb31ab794dce024efd6eeb580696abbf9111adddc65f8ab7945ff214e726f19"' }>
                                            <li class="link">
                                                <a href="pipes/EffortPipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >EffortPipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/EscapeHtmlPipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >EscapeHtmlPipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/HashRatePipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >HashRatePipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/MarkdownPipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >MarkdownPipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/RemoveTrailingZerosPipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >RemoveTrailingZerosPipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/ShruggiePipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >ShruggiePipe</a>
                                            </li>
                                            <li class="link">
                                                <a href="pipes/TimeAgoPipe.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >TimeAgoPipe</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/PostModule.html" data-type="entity-link" >PostModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-PostModule-0560fd9441b019eefb4d8dfc9f794a6bfa9e4efbcb47d76f208115dad0e4e094526db7bf37c101bb49fffeb902e8dab1a00fcc57ffbf51ab2a0e82b1b9d6190b"' : 'data-target="#xs-components-links-module-PostModule-0560fd9441b019eefb4d8dfc9f794a6bfa9e4efbcb47d76f208115dad0e4e094526db7bf37c101bb49fffeb902e8dab1a00fcc57ffbf51ab2a0e82b1b9d6190b"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-PostModule-0560fd9441b019eefb4d8dfc9f794a6bfa9e4efbcb47d76f208115dad0e4e094526db7bf37c101bb49fffeb902e8dab1a00fcc57ffbf51ab2a0e82b1b9d6190b"' :
                                            'id="xs-components-links-module-PostModule-0560fd9441b019eefb4d8dfc9f794a6bfa9e4efbcb47d76f208115dad0e4e094526db7bf37c101bb49fffeb902e8dab1a00fcc57ffbf51ab2a0e82b1b9d6190b"' }>
                                            <li class="link">
                                                <a href="components/PostComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >PostComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/PostRoutingModule.html" data-type="entity-link" >PostRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/RootModule.html" data-type="entity-link" >RootModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-RootModule-dea61f5a83f5c521944c1dc35f243ec2d7164352b9623a3719e77213b97a5428932cfe1505c24ba320875fa8d7de72b55955c840cfa9e770856aa0537d71919f"' : 'data-target="#xs-components-links-module-RootModule-dea61f5a83f5c521944c1dc35f243ec2d7164352b9623a3719e77213b97a5428932cfe1505c24ba320875fa8d7de72b55955c840cfa9e770856aa0537d71919f"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-RootModule-dea61f5a83f5c521944c1dc35f243ec2d7164352b9623a3719e77213b97a5428932cfe1505c24ba320875fa8d7de72b55955c840cfa9e770856aa0537d71919f"' :
                                            'id="xs-components-links-module-RootModule-dea61f5a83f5c521944c1dc35f243ec2d7164352b9623a3719e77213b97a5428932cfe1505c24ba320875fa8d7de72b55955c840cfa9e770856aa0537d71919f"' }>
                                            <li class="link">
                                                <a href="components/RootComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >RootComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/RootRoutingModule.html" data-type="entity-link" >RootRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/SettingsModule.html" data-type="entity-link" >SettingsModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-SettingsModule-a7318366188b36a9890b00f5eb7cc05a450d179df830807924bd82c2a8d034d752b71ce08abe18c8d9b94583f821073bf86b2847622ef4a5805edf818d4d035b"' : 'data-target="#xs-components-links-module-SettingsModule-a7318366188b36a9890b00f5eb7cc05a450d179df830807924bd82c2a8d034d752b71ce08abe18c8d9b94583f821073bf86b2847622ef4a5805edf818d4d035b"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-SettingsModule-a7318366188b36a9890b00f5eb7cc05a450d179df830807924bd82c2a8d034d752b71ce08abe18c8d9b94583f821073bf86b2847622ef4a5805edf818d4d035b"' :
                                            'id="xs-components-links-module-SettingsModule-a7318366188b36a9890b00f5eb7cc05a450d179df830807924bd82c2a8d034d752b71ce08abe18c8d9b94583f821073bf86b2847622ef4a5805edf818d4d035b"' }>
                                            <li class="link">
                                                <a href="components/SettingsComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >SettingsComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/SettingsRoutingModule.html" data-type="entity-link" >SettingsRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/StatusModule.html" data-type="entity-link" >StatusModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-StatusModule-62054be6efd4a21abb8f7fc8726eb26c40b4a2556c5edfbac90644c76fb9295e78eed5058c81e3829b970fc3d9999c6526d3deafab3fcd483ed20e923c2b872e"' : 'data-target="#xs-components-links-module-StatusModule-62054be6efd4a21abb8f7fc8726eb26c40b4a2556c5edfbac90644c76fb9295e78eed5058c81e3829b970fc3d9999c6526d3deafab3fcd483ed20e923c2b872e"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-StatusModule-62054be6efd4a21abb8f7fc8726eb26c40b4a2556c5edfbac90644c76fb9295e78eed5058c81e3829b970fc3d9999c6526d3deafab3fcd483ed20e923c2b872e"' :
                                            'id="xs-components-links-module-StatusModule-62054be6efd4a21abb8f7fc8726eb26c40b4a2556c5edfbac90644c76fb9295e78eed5058c81e3829b970fc3d9999c6526d3deafab3fcd483ed20e923c2b872e"' }>
                                            <li class="link">
                                                <a href="components/NoDaemonRunningDialog.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >NoDaemonRunningDialog</a>
                                            </li>
                                            <li class="link">
                                                <a href="components/StatusComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >StatusComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/UserModule.html" data-type="entity-link" >UserModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-UserModule-54f11b95468b5065c75b60bfa4ad43edf40e6a42f847f70495cfd8a51e44e7c03d438e565f2232cdc5cb31e5c501f04e116f4a18a92756dd9297c698554c4871"' : 'data-target="#xs-components-links-module-UserModule-54f11b95468b5065c75b60bfa4ad43edf40e6a42f847f70495cfd8a51e44e7c03d438e565f2232cdc5cb31e5c501f04e116f4a18a92756dd9297c698554c4871"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-UserModule-54f11b95468b5065c75b60bfa4ad43edf40e6a42f847f70495cfd8a51e44e7c03d438e565f2232cdc5cb31e5c501f04e116f4a18a92756dd9297c698554c4871"' :
                                            'id="xs-components-links-module-UserModule-54f11b95468b5065c75b60bfa4ad43edf40e6a42f847f70495cfd8a51e44e7c03d438e565f2232cdc5cb31e5c501f04e116f4a18a92756dd9297c698554c4871"' }>
                                            <li class="link">
                                                <a href="components/UserComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >UserComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/UserRoutingModule.html" data-type="entity-link" >UserRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/VpnModule.html" data-type="entity-link" >VpnModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-VpnModule-a3af0defdcfb5cde7cb9f5e06d6bfbed7c5566a0aa9482ae85827cf3246bbb605236cdc7069f2e6263daf957ba96babd7454a4b9fec0575f7841bcffb1d142b3"' : 'data-target="#xs-components-links-module-VpnModule-a3af0defdcfb5cde7cb9f5e06d6bfbed7c5566a0aa9482ae85827cf3246bbb605236cdc7069f2e6263daf957ba96babd7454a4b9fec0575f7841bcffb1d142b3"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-VpnModule-a3af0defdcfb5cde7cb9f5e06d6bfbed7c5566a0aa9482ae85827cf3246bbb605236cdc7069f2e6263daf957ba96babd7454a4b9fec0575f7841bcffb1d142b3"' :
                                            'id="xs-components-links-module-VpnModule-a3af0defdcfb5cde7cb9f5e06d6bfbed7c5566a0aa9482ae85827cf3246bbb605236cdc7069f2e6263daf957ba96babd7454a4b9fec0575f7841bcffb1d142b3"' }>
                                            <li class="link">
                                                <a href="components/VpnComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >VpnComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/VpnRoutingModule.html" data-type="entity-link" >VpnRoutingModule</a>
                            </li>
                            <li class="link">
                                <a href="modules/WalletModule.html" data-type="entity-link" >WalletModule</a>
                                    <li class="chapter inner">
                                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ?
                                            'data-target="#components-links-module-WalletModule-d83ac783d55088a0066dda09e00b618fec9ea074325f9e4fbb900cb2d0fc837281b955330a99b8d15a904b59fcd1193d05c53aab85dbb0f2b3106329905c1df2"' : 'data-target="#xs-components-links-module-WalletModule-d83ac783d55088a0066dda09e00b618fec9ea074325f9e4fbb900cb2d0fc837281b955330a99b8d15a904b59fcd1193d05c53aab85dbb0f2b3106329905c1df2"' }>
                                            <span class="icon ion-md-cog"></span>
                                            <span>Components</span>
                                            <span class="icon ion-ios-arrow-down"></span>
                                        </div>
                                        <ul class="links collapse" ${ isNormalMode ? 'id="components-links-module-WalletModule-d83ac783d55088a0066dda09e00b618fec9ea074325f9e4fbb900cb2d0fc837281b955330a99b8d15a904b59fcd1193d05c53aab85dbb0f2b3106329905c1df2"' :
                                            'id="xs-components-links-module-WalletModule-d83ac783d55088a0066dda09e00b618fec9ea074325f9e4fbb900cb2d0fc837281b955330a99b8d15a904b59fcd1193d05c53aab85dbb0f2b3106329905c1df2"' }>
                                            <li class="link">
                                                <a href="components/BackupComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >BackupComponent</a>
                                            </li>
                                            <li class="link">
                                                <a href="components/NewComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >NewComponent</a>
                                            </li>
                                            <li class="link">
                                                <a href="components/RestoreComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >RestoreComponent</a>
                                            </li>
                                            <li class="link">
                                                <a href="components/SettingsComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >SettingsComponent</a>
                                            </li>
                                            <li class="link">
                                                <a href="components/WalletComponent.html" data-type="entity-link" data-context="sub-entity" data-context-id="modules" >WalletComponent</a>
                                            </li>
                                        </ul>
                                    </li>
                            </li>
                            <li class="link">
                                <a href="modules/WalletRoutingModule.html" data-type="entity-link" >WalletRoutingModule</a>
                            </li>
                </ul>
                </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#components-links"' :
                            'data-target="#xs-components-links"' }>
                            <span class="icon ion-md-cog"></span>
                            <span>Components</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="components-links"' : 'id="xs-components-links"' }>
                            <li class="link">
                                <a href="components/ProfileComponent.html" data-type="entity-link" >ProfileComponent</a>
                            </li>
                            <li class="link">
                                <a href="components/SettingsComponent-1.html" data-type="entity-link" >SettingsComponent</a>
                            </li>
                        </ul>
                    </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#classes-links"' :
                            'data-target="#xs-classes-links"' }>
                            <span class="icon ion-ios-paper"></span>
                            <span>Classes</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="classes-links"' : 'id="xs-classes-links"' }>
                            <li class="link">
                                <a href="classes/Atomic.html" data-type="entity-link" >Atomic</a>
                            </li>
                            <li class="link">
                                <a href="classes/LTHN.html" data-type="entity-link" >LTHN</a>
                            </li>
                        </ul>
                    </li>
                        <li class="chapter">
                            <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#injectables-links"' :
                                'data-target="#xs-injectables-links"' }>
                                <span class="icon ion-md-arrow-round-down"></span>
                                <span>Injectables</span>
                                <span class="icon ion-ios-arrow-down"></span>
                            </div>
                            <ul class="links collapse " ${ isNormalMode ? 'id="injectables-links"' : 'id="xs-injectables-links"' }>
                                <li class="link">
                                    <a href="injectables/AppService.html" data-type="entity-link" >AppService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/AuthService.html" data-type="entity-link" >AuthService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/BaseChartConfigService.html" data-type="entity-link" >BaseChartConfigService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/BlockchainService.html" data-type="entity-link" >BlockchainService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/ChartsEffects.html" data-type="entity-link" >ChartsEffects</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/CryptService.html" data-type="entity-link" >CryptService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/Effects.html" data-type="entity-link" >Effects</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/Effects-1.html" data-type="entity-link" >Effects</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/FileSystemService.html" data-type="entity-link" >FileSystemService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/FileSystemWebService.html" data-type="entity-link" >FileSystemWebService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/NetworkHashrateChart.html" data-type="entity-link" >NetworkHashrateChart</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/SettingsEffects.html" data-type="entity-link" >SettingsEffects</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/WalletService.html" data-type="entity-link" >WalletService</a>
                                </li>
                                <li class="link">
                                    <a href="injectables/WebsocketService.html" data-type="entity-link" >WebsocketService</a>
                                </li>
                            </ul>
                        </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#guards-links"' :
                            'data-target="#xs-guards-links"' }>
                            <span class="icon ion-ios-lock"></span>
                            <span>Guards</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="guards-links"' : 'id="xs-guards-links"' }>
                            <li class="link">
                                <a href="guards/AuthGuard.html" data-type="entity-link" >AuthGuard</a>
                            </li>
                        </ul>
                    </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#interfaces-links"' :
                            'data-target="#xs-interfaces-links"' }>
                            <span class="icon ion-md-information-circle-outline"></span>
                            <span>Interfaces</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? ' id="interfaces-links"' : 'id="xs-interfaces-links"' }>
                            <li class="link">
                                <a href="interfaces/AddAddressBook.html" data-type="entity-link" >AddAddressBook</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Address.html" data-type="entity-link" >Address</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/AppState.html" data-type="entity-link" >AppState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Balance.html" data-type="entity-link" >Balance</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ChartConfigInterface.html" data-type="entity-link" >ChartConfigInterface</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ChartDifficulty.html" data-type="entity-link" >ChartDifficulty</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ChartsState.html" data-type="entity-link" >ChartsState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/CreateWallet.html" data-type="entity-link" >CreateWallet</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Destination.html" data-type="entity-link" >Destination</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/DialogData.html" data-type="entity-link" >DialogData</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/FileSystemInterface.html" data-type="entity-link" >FileSystemInterface</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetAddressBookOut.html" data-type="entity-link" >GetAddressBookOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetBulkPaymentsIn.html" data-type="entity-link" >GetBulkPaymentsIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetBulkPaymentsOut.html" data-type="entity-link" >GetBulkPaymentsOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetPaymentsIn.html" data-type="entity-link" >GetPaymentsIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetPaymentsOut.html" data-type="entity-link" >GetPaymentsOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetTransfersIn.html" data-type="entity-link" >GetTransfersIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/GetTransfersOut.html" data-type="entity-link" >GetTransfersOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Height.html" data-type="entity-link" >Height</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/IncomingTransfersIn.html" data-type="entity-link" >IncomingTransfersIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/IncomingTransfersOut.html" data-type="entity-link" >IncomingTransfersOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/IntegratedAddress.html" data-type="entity-link" >IntegratedAddress</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/LogEntry.html" data-type="entity-link" >LogEntry</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/LogsState.html" data-type="entity-link" >LogsState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/MakeIntegratedAddressIn.html" data-type="entity-link" >MakeIntegratedAddressIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/MakeUriIn.html" data-type="entity-link" >MakeUriIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Message.html" data-type="entity-link" >Message</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/OpenWallet.html" data-type="entity-link" >OpenWallet</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ParseUri.html" data-type="entity-link" >ParseUri</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Payment.html" data-type="entity-link" >Payment</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/ProfileState.html" data-type="entity-link" >ProfileState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/QueryKeyIn.html" data-type="entity-link" >QueryKeyIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/QueryKeyOut.html" data-type="entity-link" >QueryKeyOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Response.html" data-type="entity-link" >Response</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SettingsState.html" data-type="entity-link" >SettingsState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SplitIntegratedAddressOut.html" data-type="entity-link" >SplitIntegratedAddressOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/StoreOut.html" data-type="entity-link" >StoreOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SweepAllIn.html" data-type="entity-link" >SweepAllIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SweepAllOut.html" data-type="entity-link" >SweepAllOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/SweepDustOut.html" data-type="entity-link" >SweepDustOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Task.html" data-type="entity-link" >Task</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Transfer.html" data-type="entity-link" >Transfer</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/TransferIn.html" data-type="entity-link" >TransferIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/TransferOut.html" data-type="entity-link" >TransferOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/TransferSplitIn.html" data-type="entity-link" >TransferSplitIn</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/TransferSplitOut.html" data-type="entity-link" >TransferSplitOut</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/Uri.html" data-type="entity-link" >Uri</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/UserMeta.html" data-type="entity-link" >UserMeta</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/UserOptions.html" data-type="entity-link" >UserOptions</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/UsersState.html" data-type="entity-link" >UsersState</a>
                            </li>
                            <li class="link">
                                <a href="interfaces/UserState.html" data-type="entity-link" >UserState</a>
                            </li>
                        </ul>
                    </li>
                    <li class="chapter">
                        <div class="simple menu-toggler" data-toggle="collapse" ${ isNormalMode ? 'data-target="#miscellaneous-links"'
                            : 'data-target="#xs-miscellaneous-links"' }>
                            <span class="icon ion-ios-cube"></span>
                            <span>Miscellaneous</span>
                            <span class="icon ion-ios-arrow-down"></span>
                        </div>
                        <ul class="links collapse " ${ isNormalMode ? 'id="miscellaneous-links"' : 'id="xs-miscellaneous-links"' }>
                            <li class="link">
                                <a href="miscellaneous/enumerations.html" data-type="entity-link">Enums</a>
                            </li>
                            <li class="link">
                                <a href="miscellaneous/functions.html" data-type="entity-link">Functions</a>
                            </li>
                            <li class="link">
                                <a href="miscellaneous/variables.html" data-type="entity-link">Variables</a>
                            </li>
                        </ul>
                    </li>
                        <li class="chapter">
                            <a data-type="chapter-link" href="routes.html"><span class="icon ion-ios-git-branch"></span>Routes</a>
                        </li>
                    <li class="chapter">
                        <a data-type="chapter-link" href="coverage.html"><span class="icon ion-ios-stats"></span>Documentation coverage</a>
                    </li>
                    <li class="divider"></li>
                    <li class="copyright">
                        Documentation generated using <a href="https://compodoc.app/" target="_blank">
                            <img data-src="images/compodoc-vectorise.png" class="img-responsive" data-type="compodoc-logo">
                        </a>
                    </li>
            </ul>
        </nav>
        `);
        this.innerHTML = tp.strings;
    }
});