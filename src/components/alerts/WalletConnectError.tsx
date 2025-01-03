import React from 'react';


const WalletConnectError: React.FC = () => {
    return (
        <div className='flex p-8 content justify-center items-center'>
            <div id="alert-additional-content-2" className=" p-4 mb-4 text-red-800 border border-red-300 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400 dark:border-red-800" role="alert">
                <div className="flex items-center justify-center">
                    <svg className="flex-shrink-0 w-5 h-5 me-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5ZM9.5 4a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 15H8a1 1 0 0 1 0-2h1v-3H8a1 1 0 0 1 0-2h2a1 1 0 0 1 1 1v4h1a1 1 0 0 1 0 2Z" />
                    </svg>
                    <span className="sr-only">Info</span>
                    <h3 className="text-2xl font-large">Wallet Not Connected</h3>
                </div>
                <div className="mt-2 mb-4 text-lg">
                    This Page requires a user to be connected to Arweave Wallet. Please use the connect button or the toggle button
                    in the top right corner of the screen to connect.
                </div>
            </div>
        </div>
    )
}

export default WalletConnectError