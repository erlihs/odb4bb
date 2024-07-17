

// Types for package pck_app_demo

type TDbSize = {
    tablespaceName: string;
    segmentName: string;
    bytes: number;
};

type TAce = {
    host: string;
    lowerPort: number;
    upperPort: number;
    privilege: string;
    status: string;
};

