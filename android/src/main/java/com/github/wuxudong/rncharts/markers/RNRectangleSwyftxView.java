package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.drawable.Drawable;
import androidx.core.content.res.ResourcesCompat;
import android.text.TextUtils;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.github.mikephil.charting.charts.Chart;
import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.data.CandleEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.MPPointF;
import com.github.mikephil.charting.utils.Utils;
import com.github.wuxudong.rncharts.R;

import java.util.Map;



public class RNRectangleSwyftxView extends MarkerView {

    private TextView tvPrimary;
    private TextView tvSecondary;
    private LinearLayout container;

    private Drawable backgroundLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_left, null);
    private Drawable background = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_test, null);
    private Drawable backgroundRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_right, null);

    private Drawable backgroundTopLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_left, null);
    private Drawable backgroundTop = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top, null);
    private Drawable backgroundTopRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_right, null);

    private int digits = 0;

    public RNRectangleSwyftxView(Context context) {
        super(context, R.layout.highlight_marker);

        container = (LinearLayout) findViewById(R.id.highlight_marker_content);
        tvPrimary = (TextView) findViewById(R.id.highlight_label_primary);
        tvSecondary = (TextView) findViewById(R.id.highlight_label_secondary);

    }

    public void setDigits(int digits) {
        this.digits = digits;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight) {
        String textPrimary;
        String textSecondary;

        if (e instanceof CandleEntry) {
            CandleEntry ce = (CandleEntry) e;
            textPrimary = Utils.formatNumber(ce.getClose(), digits, false);
            textSecondary = Utils.formatNumber(ce.getClose(), digits, false);
        } else {
            textPrimary = Utils.formatNumber(e.getY(), digits, false);
            textSecondary = Utils.formatNumber(e.getY(), digits, false);
        }

        if (e.getData() instanceof Map) {
            if (((Map) e.getData()).containsKey("marker")) {

                Object primaryText = ((Map) ((Map) e.getData()).get("marker")).get("primaryText");
                Object secondaryText = ((Map) ((Map) e.getData()).get("marker")).get("secondaryText");

                textPrimary = primaryText.toString();
                textSecondary = secondaryText.toString();
            }
        }

        if (TextUtils.isEmpty(textPrimary)) {
            tvPrimary.setVisibility(GONE);
        } else {
            tvPrimary.setText(textPrimary);
            tvPrimary.setVisibility(VISIBLE);
        }

        if (TextUtils.isEmpty(textSecondary)) {
            tvSecondary.setVisibility(GONE);
        } else {
            tvSecondary.setText(textSecondary);
            tvSecondary.setVisibility(VISIBLE);
        }

        super.refreshContent(e, highlight);
    }

    @Override
    public MPPointF getOffset() {
        return new MPPointF(-getWidth() / 2, -getHeight());
    }

    @Override
    public MPPointF getOffsetForDrawingAtPoint(float posX, float posY) {

        MPPointF offset = getOffset();

        MPPointF offset2 = new MPPointF();

        offset2.x = offset.x;
        offset2.y = offset.y;

        Chart chart = getChartView();

        float width = getWidth();

        // 30 magic number based on required negative margin in LineChart.tsx in react native
        if (posX + offset2.x < 30) {
            offset2.x = 0;
        } else if (chart != null && posX + width + offset2.x > (chart.getWidth() - 30)) {
            offset2.x = -width;
        }

        offset2.y = -posY;
        return offset2;
    }

    public TextView getPrimaryTv() {
        return tvPrimary;
    }

    public TextView getSecondaryTv() {
        return tvSecondary;
    }

    public LinearLayout getContainer() {
        return container;
    }

}


