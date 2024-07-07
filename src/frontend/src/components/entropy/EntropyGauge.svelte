<script lang="ts">
    import { onMount } from "svelte";
    import type { EntropyData } from "../../ic-agent/declarations/main";

    export let entropyData: EntropyData;
    let percentage: number = 0;
    let canvas: HTMLCanvasElement;
    let ctx: CanvasRenderingContext2D | null;

    $: {
        percentage =
            entropyData === undefined
                ? 0
                : Number(entropyData.currentEntropy) /
                  Number(entropyData.entropyThreshold);
    }

    onMount(() => {
        ctx = canvas.getContext("2d");
    });
    const colorStops = [
        { percent: 0, color: "rgba(0, 128, 0, 0.9)" }, // Pure Green
        { percent: 0.33, color: "rgba(255, 255, 0, 0.9)" }, // Pure Yellow
        { percent: 0.66, color: "rgba(255, 128, 0, 0.9)" }, // Pure Orange
        { percent: 1, color: "rgba(255, 0, 0, 0.9)" }, // Pure Red
    ];
    function drawGauge(): void {
        if (!ctx || !entropyData) return;

        const width = canvas.width;
        const height = canvas.height;
        const centerX = width / 2;
        const centerY = height / 2 - 20;
        const radius = Math.min(width, height / 2) - 50;

        ctx.clearRect(0, 0, width, height);

        // Create gradient
        const gradient = ctx.createConicGradient(Math.PI, centerX, centerY);
        colorStops.forEach((stop) => {
            gradient.addColorStop(stop.percent / 2, stop.color);
        });

        let lineWidth = 50;
        // Draw the gauge arc
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, Math.PI, 0);
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = gradient;
        ctx.lineCap = "butt";
        ctx.stroke();

        // Draw black border
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius + lineWidth / 2, Math.PI, 0);
        ctx.lineWidth = 4;
        ctx.strokeStyle = "#000";
        ctx.lineCap = "butt";
        ctx.stroke();

        ctx.beginPath();
        ctx.arc(centerX, centerY, radius - lineWidth / 2, Math.PI, 0);
        ctx.lineWidth = 4;
        ctx.strokeStyle = "#000";
        ctx.lineCap = "butt";
        ctx.stroke();

        // Draw end borders
        ctx.beginPath();
        ctx.moveTo(centerX - radius - lineWidth / 2, centerY);
        ctx.lineTo(centerX - radius + lineWidth / 2, centerY);
        ctx.moveTo(centerX + radius - lineWidth / 2, centerY);
        ctx.lineTo(centerX + radius + lineWidth / 2, centerY);
        ctx.lineWidth = 4;
        ctx.strokeStyle = "#000";
        ctx.stroke();

        // Draw needle
        drawNeedle(centerX, centerY, radius, percentage);

        // Draw current entropy value
        ctx.fillStyle = "#F3F4F6";
        ctx.font = "bold 28px Arial";
        ctx.textAlign = "center";
        ctx.fillText(
            entropyData.currentEntropy.toString() + "🔥",
            centerX + 10,
            centerY + 40,
        );

        // Draw labels (if needed)
        drawLabels(centerX, centerY, radius, entropyData.entropyThreshold);
    }
    function drawNeedle(
        centerX: number,
        centerY: number,
        radius: number,
        percent: number,
    ): void {
        if (!ctx) return;

        const angle = (1 - percent) * Math.PI;
        const needleLength = radius - 10;

        // Draw black outline
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(
            centerX + needleLength * Math.cos(angle),
            centerY - needleLength * Math.sin(angle),
        );
        ctx.lineWidth = 12;
        ctx.lineCap = "round";
        ctx.strokeStyle = "#000";
        ctx.stroke();

        // Draw white center
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(
            centerX + needleLength * Math.cos(angle),
            centerY - needleLength * Math.sin(angle),
        );
        ctx.lineWidth = 2;
        ctx.lineCap = "round";
        ctx.strokeStyle = "#FFF";
        ctx.stroke();

        // Draw needle base outline
        ctx.beginPath();
        ctx.arc(centerX, centerY, 10, 0, Math.PI * 2);
        ctx.fillStyle = "#000";
        ctx.fill();

        // Draw needle base center
        ctx.beginPath();
        ctx.arc(centerX, centerY, 6, 0, Math.PI * 2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
    }

    function drawLabels(
        centerX: number,
        centerY: number,
        radius: number,
        threshold: bigint,
    ): void {
        if (!ctx) return;

        ctx.font = "bold 16px Arial";
        ctx.fillStyle = "#F3F4F6";
        ctx.textAlign = "center";

        const labelRadius = radius + 25;

        let drawLabel = (step: number) => {
            const angle = Math.PI + step * Math.PI;
            const x = centerX + radius * Math.cos(angle);
            const y = centerY + labelRadius * Math.sin(angle) + 20; // Moved down by 20px

            const value = (BigInt(step * 100) * threshold) / BigInt(100);
            ctx!.fillText(value.toString(), x, y);
        };
        drawLabel(0);
        drawLabel(1);
    }

    $: if (ctx && entropyData) drawGauge();
</script>

<div class="gauge-container">
    <canvas bind:this={canvas} width="400" height="300"></canvas>
</div>

<style>
    .gauge-container {
        width: 400px;
        height: 200px;
        margin: 0 auto;
        /* Add a subtle background to enhance the gauge appearance */
        /* background: linear-gradient(to bottom, #f5f5f5, #e0e0e0); */
    }
</style>
